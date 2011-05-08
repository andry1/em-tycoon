kt = __kyototycoon__
db = kt.db

function testscript(inmap, outmap)
  kt.log("system", "testscript called")
  for k,v in pairs(inmap) do
    outmap[k] = v
  end
  return kt.RVSUCCESS
end