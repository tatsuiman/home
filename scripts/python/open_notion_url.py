import os, sys, traceback
from notion.client import NotionClient

token = os.getenv("NOTION_TOKEN")
client = NotionClient(token_v2=token)
page = client.get_block(sys.argv[1])

markdown_texts = []


def get_collection_rows(collection):
    collection_texts = ["| タイトル | ステータス | 担当者 |", "| --- | --- | --- |"]
    for row in collection.get_rows():
        try:
            status_text = getattr(row, "status", [])
            person_list = getattr(row, "person", [])
            title_text = f"[{row.title_plaintext}]({row.get_browseable_url()})"
            if len(person_list) == 0:
                person_text = ""
            else:
                person_text = ",".join([person.email for person in person_list])
            collection_texts.append(f"| {title_text} | {status_text} | {person_text} |")
        except Exception as e:
            traceback.print_exc()
    return "\n".join(collection_texts)


def extract_markdown_texts(children, indent_level=0):
    for child in children:
        block_type = child.type
        indent = "    " * indent_level
        try:
            if block_type == "page":
                markdown_texts.append(f"🔗 {child.title_plaintext}")
            elif block_type == "bulleted_list":
                markdown_texts.append(f"{indent}• {child.title_plaintext}")
            elif block_type == "collection_view":
                for view in child.views:
                    collection_text = get_collection_rows(view.collection)
                    markdown_texts.append(f"📊 collection_view")
                    markdown_texts.append(collection_text)
            elif block_type == "sub_header":
                markdown_texts.append(f"## {child.title_plaintext}")
            elif block_type == "sub_sub_header":
                markdown_texts.append(f"### {child.title_plaintext}")
            elif block_type == "text":
                markdown_texts.append(child.title_plaintext)
            elif block_type == "callout":
                markdown_texts.append(f"> {child.title_plaintext}")
            elif block_type == "code":
                markdown_texts.append(f"```\n{child.title_plaintext}\n```")
            elif block_type == "collection_view_page":
                markdown_texts.append(
                    f"📄 collection_view_page: {child.title_plaintext}"
                )
            elif block_type == "column_list":
                pass
            elif block_type == "divider":
                markdown_texts.append("---")
            elif block_type == "external_object_instance":
                pass
            elif block_type == "file":
                markdown_texts.append(f"[📁 file]({child.display_source})")
            elif block_type == "header":
                markdown_texts.append(f"# {child.title_plaintext}")
            elif block_type == "image":
                markdown_texts.append(f"[🖼 image]({child.display_source})")
            elif block_type == "numbered_list":
                markdown_texts.append(f"{indent}1. {child.title_plaintext}")
            elif block_type == "table":
                pass
            elif block_type == "table_row":
                pass
            elif block_type == "toggle":
                markdown_texts.append(f"🔽 toggle: {child.title_plaintext}")
            else:
                print(f"unknown block type: {block_type}")
        except Exception as e:
            print(f"error: {e} {block_type}")

        if block_type in [
            "bulleted_list",
            "sub_header",
            "sub_sub_header",
            "column_list",
            "divider",
            "numbered_list",
            "toggle",
        ]:
            extract_markdown_texts(child.children, indent_level + 1)


if page.type == "page":
    extract_markdown_texts(page.children)


print("\n".join(markdown_texts))
