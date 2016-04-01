
JSON = (loadfile "JSON.lua")()
local ltn12  = require "ltn12"
local io     = require "io"
local socket = require "socket"
local http = require "socket.http"

socket.http.TIMEOUT = 10

local function http_send_get(host, data)
    local req, resp = {}, {}
    local raw_data = data or {}
	local i = 0

    req = "http://"..host .. "/line/real_line_schedule_list?"
    for k, v in pairs(raw_data) do
        if k and v then
			if i > 0 then
				req = string.format("%s&%s=%s", req, k, v)
			else
				req = string.format("%s%s=%s", req, k, v)
			end
        end
		i = i + 1
    end
	--req="119.75.222.10"
	print("req=" .. req)
    local start = socket.gettime()
    local one, code, headers, status = http.request({
        url = req,
		method = "GET",
        headers = {
            ["User-Agent"] = "Mozilla/5.0 (Linux; U; Android 5.1; zh-cn; m2 note Build/LMY47D) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1",
            ["Content-Length"] = "0",
            ["Connection"] = "Keep-Alive",
			["Accept-Encoding"] = "gzip"
        },
        sink = ltn12.sink.table(resp),
    })
    local t = socket.gettime() - start

    if code and code == 200 and resp then
        --[[print("POST response:\n" .. table.concat(resp))
        return table.concat(resp)]]
		return resp
    else
        print("Request failed, host: " .. host
                .. " time: " .. tostring(t) .. " "
                .. " code: " .. tostring(code) .. " "
                .. "status: " .. tostring(status))
        return nil --tostring(code)
    end

end

local function parse_schedule(res)
		--{"ret":0,"msg":"","server_time":"2016-01-15 08:30:14","data":{"schedule_list":[{"date":"2016-01-15","total_seat":1,"valid_seat":1,"status":1,"original_price":10,"date_price":7,"ticket_status":2},{"date":"2016-01-18","total_seat":1,"valid_seat":1,"status":1,"original_price":10,"date_price":7,"ticket_status":2},{"date":"2016-01-19","total_seat":1,"valid_seat":1,"status":1,"original_price":10,"date_price":7,"ticket_status":2},{"date":"2016-01-20","total_seat":1,"valid_seat":1,"status":1,"original_price":10,"date_price":7,"ticket_status":2},{"date":"2016-01-21","total_seat":1,"valid_seat":1,"status":1,"original_price":10,"date_price":7,"ticket_status":2},{"date":"2016-01-22","total_seat":1,"valid_seat":1,"status":1,"original_price":10,"date_price":7,"ticket_status":2},{"date":"2016-01-25","total_seat":1,"valid_seat":1,"status":1,"original_price":10,"date_price":7,"ticket_status":2},{"date":"2016-01-26","total_seat":1,"valid_seat":1,"status":1,"original_price":10,"date_price":7,"ticket_status":2},{"date":"2016-01-27","total_seat":1,"valid_seat":1,"status":1,"original_price":10,"date_price":7,"ticket_status":2},{"date":"2016-01-28","total_seat":1,"valid_seat":1,"status":1,"original_price":10,"date_price":7,"ticket_status":2}],"month_schedule_list":[]}}	

		local data = res.data
		if not data then
			print("res.data is nil")
			return
		end

		local schedule_list = data.schedule_list
		if not schedule_list then
			print("schedule_list is nil")
			return
		end

		local month_schedule_list = data.month_schedule_list
		local month_len = #month_schedule_list

		local have_month_ticket = 0

		if month_len ~= 0 then
			local mdata = month_schedule_list[1]
			if 2 == mdata.ticket_status  then
				have_month_ticket = 1
			end
		end

		if 1 == have_month_ticket then
			print("!!!Month ticket!!!")
			local cmda="sleep 3;mail -s \"".."month".."\" -r \"renleilei5@btte.net\" renleilei5@btte.net </dev/null"
			os.execute(cmda)
			local cmdb="sleep 3;mail -s \"".."month".."\" -r \"stoneforfun@aliyun.com\" stoneforfun@aliyun.com </dev/null"
			os.execute(cmdb)
			os.execute("sleep 190")
		end
			
		local len = #schedule_list
		local i = 1

		while i <= len do
			local day = schedule_list[i]
			print(day.date.."  "..day.ticket_status)	
			--if day.date == "2016-01-29" or day.date == "2016-01-30" or day.date == "2016-01-31" then
				--print("day="..day.date.." ticket_status="..day.ticket_status);
				if 2 == day.ticket_status then
					print("!!!Ticket!!! "..day.date.." "..day.ticket_status)
					local cmda="sleep 3;mail -s \""..day.date.."\" -r \"renleilei5@btte.net\" renleilei5@btte.net </dev/null"
					os.execute(cmda)
					local cmdb="sleep 3;mail -s \""..day.date.."\" -r \"stoneforfun@aliyun.com\" stoneforfun@aliyun.com </dev/null"
					os.execute(cmdb)
					os.execute("sleep 190")
				end
			--end
			
			i=i+1
		end


end

local function make_request()
	--line_code=3097-14847-7786&version=2.0.0&user_id=452861&mobile=18610316981&device_id=867569028002844&device_uuid=172957c7-9c35-41d3-bbe0-c7bf30a72774&login_type=1&device_type=1&source=1&city_code=010&lat=39.951769&lng=116.418559&device_model=m2+note&sys_version=5.1&gps_sampling_time=1452817268&ddb_token=&cache_time=1452817814789

	local data = {}
	local host="api.dadabus.com"
	local result = {}

	data={
		--line_code="3097-14847-7786",
		line_code="2978-7785-5841", -- 7:00
		version="2.0.0",
		user_id="452861",
		mobile="18610316981",
		device_id="867569028002844",
		device_uuid="172957c7-9c35-41d3-bbe0-c7bf30a72774",
		login_type="1",
		device_type="1",
		source="1",
		city_code="010",
		lat="39.951769",
		lng="116.418559",
		device_model="m2+note",
		sys_version="5.1",
		gps_sampling_time=os.time(),--"1452817268",
		ddb_token="",
		cache_time=math.ceil(socket.gettime()*1000), --"1452817814789"
	}


	result = http_send_get(host, data)

	if not result then
		return nil
	end
	
	if type(result) == 'table' then

		local data, schedule_list = {}, {}
		print("----".. type(result).. "====".. table.concat(result))
		for k, v in pairs(result) do
			--print("k="..k.."v="..v);
			if v ~= nil and type(v) == 'string' then
				--print("v="..v)
				local val = JSON:decode(v)
				if type(val) == 'table' then
					print("val.ret=" .. val.ret)
					if val.ret == 0 then
						parse_schedule(val)
					end
				end
			end
		end
	end

end

local function main()
	while true do
		make_request()
		os.execute("echo -n \"Now is \"; " .."date +\"20%y-%m-%d %k:%M:%S\"")
		os.execute('sleep 30')
	end
end

main()

