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

function generate1KStrings()
  local table = {}
  for i = 1,9 do
    local oneKString = tostring(i)
    for j = 1, 1024 do
      oneKString = oneKString .. tostring(i)
    end
    table[i] = oneKString .. "\n"
  end
  return table
end

function communicateWithClient(client, responseArray)
  local line, err = client:receive()
  
  if not err then
    requestedNumber = tonumber(line)
    if(requestedNumber > 0 and requestedNumber < 10) then
      client:send(responseArray[requestedNumber])
    end
  end

  return line
end

-- Verify what mode is running
if(arg[1] == "close") then
  closeConnection = true
elseif (arg[1] == "keepalive") then
  closeConnection = false
else
  print ("Run the script with either close or keepalive as the first argument.")
  return
end

-- Generate 1K strings for responses
possibleResponses = generate1KStrings()

-- Open TCP socket and tell user where to connect
local socket  = require("socket")
local server  = assert(socket.bind("*", 5500))
local ip, port = server:getsockname();
print("This is the server process. To connect, please use localhost and port " .. port)

server:settimeout(10)
local client = nil
while(true) do
    
    if(not client) then
      client = server:accept()
    else
      local request = communicateWithClient(client, possibleResponses)
      
      if(closeConnection) then
        client:close()
        client = nil
      else
        
        -- connection was closed
        if(not request) then
          client:close()
          client = nil
        end
        
      end
    end
end

client:close()
