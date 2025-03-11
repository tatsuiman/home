from notion_util import Notion, markdown_to_notion_blocks
import os
import sys


def add_notion_page(database_id, page_title, page_content):
    try:
        notion = Notion()
        # Notionのプロパティを設定
        properties = {}
        # 新しいページを作成
        res = notion.create_notion_page(database_id, page_title, properties)
        # Markdownファイルを読み込む
        blocks = markdown_to_notion_blocks(page_content)
        # Notionページにブロックを追加
        notion.append_blocks_to_page(res["id"], blocks)
    except Exception as e:
        print(e)
        return


# このコマンドは、Markdown形式のコンテンツをNotionページに追加します。
if __name__ == "__main__":
    DATABASE_ID = os.getenv("NOTION_DATABASE_ID")
    page_title = sys.argv[1]
    page_content = sys.stdin.read()
    add_notion_page(DATABASE_ID, page_title, page_content)
