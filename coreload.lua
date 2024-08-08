local i
do
  local gpu
  _G.CORELOAD_VERSION = "Coreload V1"
  local sy = 1
  local w,h
  local function bi(a, m, ...)
    local r = table.pack(pcall(component.invoke, a, m, ...))
    if not r[1] then
      return nil, r[2]
    else
      return table.unpack(r, 2, r.n) 
    end
  end
  local function gk(t)
    e,_,a,_,_ = computer.pullSignal(t)
    gpu.set(1,1,e..string.char(a))
    if e == "key_down" then
      return string.char(a)
    else
      return nil
    end
  end
  local function pr(str,xo)
    if gpu then
      if xo==nil then
        xo=0
      end
      gpu.set(1+xo,sy,str)
      sy=sy+1
    end
  end
  function hcf()
    local ts = os.time()
    while 1 do
        if os.time() - ts >= 0.5 then
            coroutine.yield()
        end
    end
  end
  local function sg(bg,fg)
    if gpu then
      gpu.setBackground(bg)
      gpu.setForeground(fg)
    end
  end
  local function blbg()
    local e = false
    while not e do
      sg(0x0000ff,0x000000)
      gpu.fill(1, 1, w, h, " ")
      sg(0x000000,0xffffff)
      gpu.fill(2, 2, w-2, h-2, " ")
      sy=1
      pr("Coreload Options",1)
      sy=3
      pr("Type 1 to boot from a specific disk and file (WIP)",2)
      pr("Type 2 to boot from a network file (requires internet card) (WIP)",2)
      pr("Type 3 to continue boot",2)
      k=gk()
      if k == "1" then
        error("not implemented")
      elseif k == "2" then
        error("not implemented")
      elseif k == "3" then
        e = 1
      end
    end
  end
  local ee = component.list("eeprom")()
  computer.getBootAddress = function()
    return bi(ee, "getData")
  end
  computer.setBootAddress = function(a)
    return bi(ee, "setData", a)
  end
  do
    screen = component.list("screen", 1)()
    gpu = screen and component.list("gpu", 1)()
    if gpu then
        gpu = component.proxy(gpu)
        if not gpu.getScreen() then
          bi(gpu, "bind", screen)
        end
        w, h = gpu.maxResolution()
        gpu.setResolution(w, h)
        sg(0xFFFFFF,0x000000)
        gpu.fill(1, 1, w, h, " ")
    end
  end
  pr(CORELOAD_VERSION)
  local function tlf(a)
    local h, r = bi(a, "open", "/boot/coreload/coreload.lua")
    if not h then
      return nil, r
    end
    local b = ""
    repeat
      local d, r = bi(a, "read", h, math.maxinteger or math.huge)
      if not d and r then
        return nil, r
      end
      b = b .. (d or "")
    until not d
    bi(a, "close", h)
    return load(b, "=i")
  end
  pr("Hold 'b' to enter boot menu",2)
  if gk(1)=="b" then
    blbg()
  end
  local r
  if computer.getBootAddress() then
    i, r = tlf(computer.getBootAddress())
  end
  if not i then
    computer.setBootAddress()
    for a in component.list("filesystem") do
      pr("attempting load from " .. a:sub(1, 5))
      i, r = tlf(a)
      if i then
        computer.setBootAddress(a)
        break
      end
    end
  end
  if not i then
    computer.beep(1000, 1)
    pr("no boot device")
    hcf()
  end
end
return i()