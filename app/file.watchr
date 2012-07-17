`couchapp push`

def notify(type,message)
  `growlnotify -t "#{type}" -m "#{message}"`
  `notify-send "#{type} - #{message}" -i /usr/share/icons/Humanity/status/128/dialog-warning.svg &`
end

watch ( '.*\.coffee$' ) { |match|
  puts "\nCompiling:\t\t#{match}"
  result = `coffee --bare --compile #{match} 2>&1`
  if result.index "In"
    notify("CoffeeScript error", result)
    puts "\n\nCoffeescript error\n******************\n#{result}"
  else
    `couchapp push`
    docco_result = `docco #{match}`
    puts "\nDocco-menting:\t\t#{match}\n"
  end
}

watch ( '.*\.less$' ) { |match| 
  puts "\nCompiling:\t\t#{match}"
  result = `lessc #{match} > #{match}.css`
  if result.index "Error"
    notify("LESS error",result)
    puts "\n\nLESS error\n******************\n#{result}"
  else
    `couchapp push`
  end
}

watch ( '.*\.css$|.*\.js$|.*\.html$|.*\.json$' ) { |match| 
  puts "\nUpdating:\t\t#{match}\nPushing to couchapp\n\n"
  `couchapp push`
}




