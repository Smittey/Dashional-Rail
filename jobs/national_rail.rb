require 'uri'
require 'net/http'
require 'openssl'
require 'nokogiri'
require "json"
require 'active_support/core_ext/hash'

token = ""
crs = ""
numRows = "8"

SCHEDULER.every "30s", :first_in => 0 do |job|

    url = URI("https://lite.realtime.nationalrail.co.uk/OpenLDBWS/ldb11.asmx")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Post.new(url)
    request["content-type"] = 'text/xml'
    request["cache-control"] = 'no-cache'
    request.body = "<?xml version=\"1.0\"?><SOAP-ENV:Envelope xmlns:SOAP-ENV=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:tns=\"http://thalesgroup.com/RTTI/2017-10-01/ldb/\"  xmlns:mns1=\"http://thalesgroup.com/RTTI/2013-11-28/Token/types\"><SOAP-ENV:Header><mns1:AccessToken><mns1:TokenValue>#{token}</mns1:TokenValue></mns1:AccessToken></SOAP-ENV:Header><SOAP-ENV:Body><tns:GetDepartureBoardRequest><tns:numRows>#{numRows}</tns:numRows><tns:crs>#{crs}</tns:crs></tns:GetDepartureBoardRequest></SOAP-ENV:Body></SOAP-ENV:Envelope>"

    response = http.request(request)

    parsed_json = Hash.from_xml(response.read_body).to_json 
    data = JSON.parse(parsed_json)

    stationMessage = data.dig("Envelope", "Body", "GetDepartureBoardResponse", "GetStationBoardResult", "nrccMessages")
    
    trains = []
    digResult = data.dig("Envelope", "Body", "GetDepartureBoardResponse", "GetStationBoardResult", "trainServices","service")

    if(digResult != nil)

        services = data['Envelope']['Body']['GetDepartureBoardResponse']['GetStationBoardResult']['trainServices']['service']

        if(services.kind_of?(Array))
        
            data['Envelope']['Body']['GetDepartureBoardResponse']['GetStationBoardResult']['trainServices']['service'].each do |child|
                
                
                isValidTime = Time.parse(child['etd']) rescue nil

                if isValidTime 
                    timeDiff = "- #{time_diff(child['std'].to_time.to_i , child['etd'].to_time.to_i )} min"
                end
                
                
                item = {
                    label: "#{child['destination']['location']['locationName']}",
                    value: "#{child['std']} (#{child['etd']}) #{timeDiff}",
                }
                
                trains.push(item)
            
            end
           
            if(stationMessage == nil)
                send_event "NationalRail", { items: trains, message: ""}
            else
            
                message = stationMessage['message']
                indexOf = stationMessage['message'].index "<A"
                message.insert (indexOf.to_i + 2), " target='_blank'"
                message = "Notice: #{message}"
                send_event "NationalRail", { items: trains, message: message}
            end
        else
        
            send_event "NationalRail", { items: [{label: "No more trains today",  value: ":("}] }

        end
        
    else
            send_event "NationalRail", { items: [{label: "Error retrieving data",  value: ""}] }
    
    end

end

def time_diff(start_time, end_time)
  seconds_diff = (start_time - end_time).to_i.abs

  hours = seconds_diff / 3600
  seconds_diff -= hours * 3600

  minutes = seconds_diff / 60
end