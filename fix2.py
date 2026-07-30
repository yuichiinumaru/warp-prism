with open("apps/catalog/test/widget_test.dart", "r") as f:
    text = f.read()

text = text.replace("debugPrint(.OVERFLOW: ${details.toString()}.);", "debugPrint('OVERFLOW: ${details.toString()}');")

with open("apps/catalog/test/widget_test.dart", "w") as f:
    f.write(text)
