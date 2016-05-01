local lapis = require("lapis")
local util = require("lapis.util")
local json = require("dkjson")
require("stridx")
local http = require("socket.http")
local app = lapis.Application()

-- This might be a problem if people query too many cds huh
local id_to_category = {}

local function handler(self)
  local url = "http://vgmdb.net"..self.req.parsed_url.path.."?"
  local query = self.params
  if query.cmd then
    local stuff = query.cmd:split(" ")
    if stuff[2] == "read" then
      stuff[3] = id_to_category[stuff[4]]
      query.cmd = table.concat(stuff, " ")
    end
  end

  url = url..util.encode_query_string(query)

  local body, status = http.request(url)

  local ret = {}

  if status == 200 then
    if url:find("cddb...query") then
      local lines = body:split("\n")
      if #lines == 1 then
        local stuff = lines[1]:split(" ")
        if stuff[1] == "200" then
          id_to_category[stuff[3]] = stuff[2]
          stuff[2] = "misc"
          body = table.concat(stuff, " ") .. "\n"
        end
      end
    elseif url:find("cddb...read") then
      local lines = body:split("\n")
      if #lines > 4 and lines[1]:sub(1,3) == "210" then
        for i=1,#lines do
          if lines[i]:sub(1, 14) == "# Disc length:" then
            table.insert(lines, i+1, "#")
            table.insert(lines, i+2, "# Revision: 14")
          end
        end
        body = table.concat(lines, "\n") .. "\n"
      end
    end
  end

  return {
    layout=false,
    content_type="text/plain",
    body
  }
end

app:get("/cddb", handler)

return app
