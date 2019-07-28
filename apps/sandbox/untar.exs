
[src, dst] = System.argv()

result = Sandbox.extract_archive(src, dst)
IO.inspect(result)
