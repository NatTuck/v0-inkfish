
[url, dst] = System.argv()

result = Sandbox.git_clone(url, dst)
IO.inspect(result)
