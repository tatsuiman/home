import sqlite3
import json
import shutil
import os
import keyring
from Crypto.Cipher import AES
import base64
import sys
import pathlib
from Crypto.Protocol.KDF import PBKDF2


# ブラウザごとのKeychain情報マッピング
BROWSER_KEYCHAIN_MAPPING = {
    "Chrome": {"service": "Chrome Safe Storage", "account": "Chrome"},
    "Arc": {"service": "Arc Safe Storage", "account": "Arc"},
    "Edge": {"service": "Microsoft Edge Safe Storage", "account": "Microsoft Edge"},
    "Brave": {"service": "Brave Safe Storage", "account": "Brave"},
    # その他のブラウザを必要に応じて追加
}


# Cookieパスからブラウザの種類を判定する関数
def detect_browser_type(cookie_path):
    if "Chrome" in cookie_path:
        return "Chrome"
    elif "Arc" in cookie_path:
        return "Arc"
    elif "Edge" in cookie_path:
        return "Edge"
    elif "Brave" in cookie_path:
        return "Brave"
    elif "Firefox" in cookie_path:
        return "Firefox"
    # その他のブラウザを追加
    else:
        return "Unknown"


# Chromeのプロファイルディレクトリから直接暗号化キーを取得する方法
def get_encryption_key_from_profile(browser_type="Chrome"):
    try:
        # Cookieパスからプロファイルディレクトリを推測
        cookie_path = sys.argv[1]
        profile_dir = os.path.dirname(cookie_path)

        # Local Stateファイルのパス
        local_state_path = os.path.join(os.path.dirname(profile_dir), "Local State")

        print(f"Local Stateファイルを探しています: {local_state_path}")

        if not os.path.exists(local_state_path):
            return None

        # Local Stateファイルからキーを抽出
        with open(local_state_path, "r", encoding="utf-8") as f:
            local_state = json.load(f)
            encrypted_key = base64.b64decode(local_state["os_crypt"]["encrypted_key"])

            # 'DPAPI' プレフィックスを除去
            if encrypted_key.startswith(b"DPAPI"):
                print("DPAPIでエンコードされたキーを見つけました")
                encrypted_key = encrypted_key[5:]

                # macOSの場合はkeychainから取得
                try:
                    import keyring

                    # ブラウザに対応するキーチェーン情報の取得
                    keychain_info = BROWSER_KEYCHAIN_MAPPING.get(
                        browser_type,
                        {"service": "Chrome Safe Storage", "account": "Chrome"},
                    )

                    key_b64 = keyring.get_password(
                        keychain_info["service"], keychain_info["account"]
                    )
                    if key_b64:
                        return base64.b64decode(key_b64)

                except Exception as e:
                    print(f"Keychain方式での取得に失敗: {e}")
            else:
                print("未知の暗号化キー形式です")
    except Exception as e:
        print(f"プロファイルからの暗号化キー取得に失敗: {e}")

    return None


# macOS の Keychain から復号に必要な鍵を取得（keyringを使用）
def get_key(browser_type="Chrome"):
    try:
        # ブラウザに対応するキーチェーン情報の取得
        keychain_info = BROWSER_KEYCHAIN_MAPPING.get(
            browser_type, {"service": "Chrome Safe Storage", "account": "Chrome"}
        )

        # Keychainからキーを取得
        key_b64 = keyring.get_password(
            keychain_info["service"], keychain_info["account"]
        )
        if key_b64 is None:
            raise Exception(f"Keychain に {browser_type} の鍵が見つかりません")

        print(f"{browser_type} のキーをKeychainから取得しました")

        # Salt, iterationsなどのパラメータ（macOS ブラウザの標準値）
        salt = b"saltysalt"
        iterations = 1003
        length = 16

        # PBKDF2を使用してキーを生成
        password = key_b64.encode("utf-8")
        key = PBKDF2(password, salt, length, iterations)

        return key
    except Exception as e:
        print(f"キー取得エラー: {str(e)}")
        sys.exit(1)


# Chromeのクッキーを復号する関数
def decrypt_cookie(encrypted_value, key, host_key, path):
    # 空のバイト列や None の場合は処理しない
    if not encrypted_value or len(encrypted_value) < 3:
        return ""

    try:
        # v10 プレフィックスチェック (Chromeの暗号化フォーマット)
        if encrypted_value.startswith(b"v10"):
            # v10 ヘッダーを削除
            encrypted_value = encrypted_value[3:]

            # AES-CBC モード（Chromeで使用）で復号化
            iv = b" " * 16  # Chromeは空白のIVを使用
            cipher = AES.new(key, AES.MODE_CBC, iv)
            decrypted = cipher.decrypt(encrypted_value)

            # 最新バージョンのChromeでは最初の32バイトはランダムデータ
            # パディングを削除
            try:
                # PKCS#7 パディングを削除
                padding_len = decrypted[-1]
                if padding_len < 17:  # 有効なパディング
                    decrypted = decrypted[:-padding_len]

                # 最初の32バイトはランダムデータ（Chrome 80以降）
                if len(decrypted) > 32:
                    decrypted = decrypted[32:]

                return decrypted.decode("utf-8")
            except Exception as padding_error:
                print(f"パディング処理エラー [{host_key}] [{path}]: {padding_error}")
                # デコードできない場合はHEX形式で出力
                return f"暗号化されたバイナリデータ(HEX): {encrypted_value.hex()}"
        else:
            # v10以外の形式、または暗号化されていない場合
            try:
                return encrypted_value.decode("utf-8", errors="replace")
            except:
                return f"不明な形式: {encrypted_value.hex()[:30]}..."
    except Exception as e:
        print(f"復号化エラー: {e}")
        return f"復号失敗: {str(e)}"


# Cookie データベースのパス
cookie_db = sys.argv[1]

# ブラウザタイプの判定
browser_type = detect_browser_type(cookie_db)
print(f"検出されたブラウザタイプ: {browser_type}")

# プロファイルディレクトリを表示（デバッグ用）
print(f"Cookie DB: {cookie_db}")

# 一時コピー（ロック回避）
temp_db = "cookies_temp.sqlite"
shutil.copy2(cookie_db, temp_db)

try:
    # SQLite に接続
    conn = sqlite3.connect(temp_db)
    conn.text_factory = bytes  # BLOBとしてデータを取得するように設定
    cursor = conn.cursor()

    # Cookie を取得するクエリ
    query = f"""
    SELECT name, encrypted_value, host_key, path
    FROM cookies
    """

    cursor.execute(query)
    key = get_key(browser_type)
    cookies = []

    for row in cursor.fetchall():
        name = row[0].decode("utf-8", errors="replace")
        encrypted_value = row[1]  # これはバイト列のまま
        host_key = row[2].decode("utf-8", errors="replace")
        path = row[3].decode("utf-8", errors="replace")

        decrypted_value = decrypt_cookie(encrypted_value, key, host_key, path)

        cookies.append(
            {"name": name, "value": decrypted_value, "domain": host_key, "path": path}
        )

    # JSON として出力し、cookies.txtに保存
    with open(sys.argv[2], "w", encoding="utf-8") as f:
        json.dump(cookies, f, indent=2, ensure_ascii=False)

except Exception as e:
    print(f"エラーが発生しました: {str(e)}")
finally:
    # クリーンアップ
    if "conn" in locals():
        conn.close()
    if os.path.exists(temp_db):
        os.remove(temp_db)
