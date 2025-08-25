'
' This script is attached to MainScene and is responsible for fetching
' and displaying the weather data.
'
sub init()
  ' Set a black background for better visibility
  m.top.backgroundColor = "0x000000FF"

  ' Observe the 'output' field of the Task node to get the result
  m.weatherTask = m.top.findNode("weatherTask")
  m.weatherTask.observeField("output", "onWeatherResult")

  ' Start the background task to fetch weather data
  m.weatherTask.control = "run"
end sub

'
' This function is executed by the Task node in the background.
' It fetches weather data from the OpenWeatherMap API.
'
function fetchWeatherData() as Object
  apiKey = "00f9de5e402140e3fa7372eeb83b989c"
  lat = "40.71"
  lon = "-74.01"
  units = "imperial" ' For Fahrenheit
  
  url = "https://api.openweathermap.org/data/2.5/weather?"
  url = url + "lat=" + lat
  url = url + "&lon=" + lon
  url = url + "&units=" + units
  url = url + "&appid=" + apiKey
  
  urlTransfer = CreateObject("roUrlTransfer")  
  urlTransfer.SetCertificatesFile("common:/certs/ca-bundle.crt")
  urlTransfer.InitClientCertificates()
  urlTransfer.SetUrl(url)
  
  response = urlTransfer.GetToString()
  
  if response <> invalid and response <> "" then
    json = ParseJson(response)
    if json <> invalid then
      return json
    else
      print "Failed to parse JSON response"
      return { error: "Error: Could not parse weather data." }
    end if
  else
    print "Failed to fetch weather data"
    return { error: "Error: Could not fetch weather data." }
  end if
end function

'
' This function is called when the weatherTask's 'output' field changes.
'
sub onWeatherResult(event as Object)
  data = event.getData()
  if data <> invalid then
    if data.DoesExist("error") then
      displayError(data.error)
    else
      updateUI(data)
    end if
  else
    displayError("Error: Invalid data from weather task.")
  end if
end sub

'
' Updates the labels in the scene with the provided weather data.
'
sub updateUI(data as Object)
  cityLabel = m.top.findNode("cityLabel")
  tempLabel = m.top.findNode("tempLabel")
  descriptionLabel = m.top.findNode("descriptionLabel")

  ' City name
  cityName = "Unknown Location"
  if data.DoesExist("name") and data.name <> invalid then
    cityName = data.name
  end if
  cityLabel.text = "Weather for " + cityName

  ' Temperature
  tempText = "N/A"
  if data.DoesExist("main") and data.main <> invalid and data.main.DoesExist("temp") then
    temp = data.main.temp
    if type(temp) = "roFloat" or type(temp) = "roInt" or type(temp) = "roDouble" then
      tempText = StrI(temp).Trim() + "°F"
    end if
  end if
  tempLabel.text = tempText

  ' Description
  descriptionText = "Current condition: N/A"
  if data.DoesExist("weather") and type(data.weather) = "roArray" and data.weather.Count() > 0 then
    description = data.weather[0].LookUp("description")
    if description <> invalid then
      descriptionText = "Current condition: " + description
    end if
  end if
  descriptionLabel.text = descriptionText
end sub

'
' Displays an error message on the screen if the API call fails.
'
sub displayError(message as String)
  errorLabel = m.top.findNode("cityLabel")
  if errorLabel <> invalid then
    errorLabel.text = message
    ' Clear other labels so stale data isn’t shown
    tempLabel = m.top.findNode("tempLabel")
    if tempLabel <> invalid then tempLabel.text = ""
    descriptionLabel = m.top.findNode("descriptionLabel")
    if descriptionLabel <> invalid then descriptionLabel.text = ""
  end if
end sub
