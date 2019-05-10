--[[ Escrever um programa cliente-servidor em Lua, usando a biblioteca LuaSocket.
 (Creio que a maneira mais simples de instalar a biblioteca para Lua 5.3
 é usando luarocks.) O serviço oferecido é o download de uma string de 1K,
 que pode ser simplesmente descartado pelo cliente (mas tem que ser
 completamente lido). Depois de aberta a conexão,
 o servidor espera uma mensagem do cliente
   (que especificaria qual string ele deseja baixar,
   mas vcs podem usar sempre a mesma) e envia uma única resposta
   a esse pedido contendo a string requisitada. O programa deve ser
   escrito em duas versões

1. O cliente e o servidor sempre fecham a conexão depois de completar a
transferência da string.

2.Cliente e servidor mantêm a conexão aberta,
e o cliente pode requisitar a string novamente usando a mesma conexão.
Nesse caso, somente quando o cliente fechar a conexão o
servidor voltará a esperar por outros clientes.
]]


-- Verify what mode is running
if(arg[1] == "close") then
  closeConnection = true
elseif (arg[1] == "keepalive") then
  closeConnection = false
else
  print ("Run the script with either close or keepalive as the first argument.")
  return
end

if arg[2] then
  numRequests = tonumber(arg[2])
else
  numRequests = 100
end

if arg[3] then
  fileOut = arg[3]
else
  fileOut = "outputtimes.txt"
end

-- Open TCP socket and connect to server
local host, port = "127.0.0.1", 5500
local socket = require("socket")
local tcp = assert(socket.tcp())

print("Requesting " .. numRequests .. " to " .. host .. ":" .. port .. " with " ..  arg[1] .." policy.")

local startTime = socket.gettime()
tcp:connect(host, port);

for i=1, numRequests do
  
  payload = math.random(9) .. "\n"
  tcp:send(payload)
  local response = tcp:receive()  

  if(closeConnection) then
    tcp:close()
    tcp = assert(socket.tcp())
    tcp:connect(host, port);
  end  
  
end

tcp:close()
local stopTime = socket.gettime()

print("TotalTime with ".. numRequests .. " was " .. tostring(stopTime - startTime) .. " seconds.")

file = io.open(fileOut, "a")
file:write(numRequests .. ";" .. tostring(stopTime - startTime) .. "\n")
file:close()
