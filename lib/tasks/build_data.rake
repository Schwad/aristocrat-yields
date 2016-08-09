task first_build: :environment do
  Quote.destroy_all
  puts "Now raking at #{Time.now}...."
  @sp_symbols = ["MMM", "AFL", "ABBV", "ABT", "APD", "ADM", "T", "ADP", "BCR", "BDX", "BMS", "B", "CAH", "CB", "CVX", "CINF", "CTAS", "CLX", "KO", "CL", "ED", "DOV", "ECL", "EMR", "XOM", "BEN", "GPC", "GWW", "HCP", "HRL", "ITW", "JNJ", "KMB", "LEG", "LOW", "MKC", "MCD", "SPGI", "MDT", "NUE", "PPG", "PEP", "PNR", "PG", "SHW", "SWK", "SYY", "TROW", "TGT", "VFC", "WMT", "WBA"]
  @basic_url = 'http://dev.markitondemand.com/MODApis/Api/v2/Quote/json?symbol='
  @sp_data_hash = {}


  @sp_symbols.each do |symbol|
    sleep 1.5
    puts "now doing symbol #{symbol}"
    #get JSON
    new_url = @basic_url + symbol
    response = HTTParty.get(new_url)
    sleep 1
    parsed_resp = JSON.parse(response)

    #get last dividend
    a = Mechanize.new
    sleep 1
    a = a.get("http://www.nasdaq.com/symbol/#{symbol}/dividend-history")
    quarterly_dividend = a.search('span#quotes_content_left_dividendhistoryGrid_CashAmount_0').text.to_f

    dividend_percentage = quarterly_dividend / parsed_resp["LastPrice"]
    @sp_data_hash[symbol] = dividend_percentage

    puts "We now have symbol #{symbol} with percentage return of: #{@sp_data_hash[symbol].round(3) * 400}%"
  end

  @sp_data_hash.each do |key, value|
     sleep 2
      new_quote = Quote.new
      new_quote.symbol = key
      new_quote.idealness = (value * 400).round(3)
      new_quote.save
  end

end

task build_out_symbols: :environment do
  while true do
    begin
      puts "Now raking at #{Time.now}...."
        @sp_symbols = ["MMM", "AFL", "ABBV", "ABT", "APD", "ADM", "T", "ADP", "BCR", "BDX", "BMS", "B", "CAH", "CB", "CVX", "CINF", "CTAS", "CLX", "KO", "CL", "ED", "DOV", "ECL", "EMR", "XOM", "BEN", "GPC", "GWW", "HCP", "HRL", "ITW", "JNJ", "KMB", "LEG", "LOW", "MKC", "MCD", "SPGI", "MDT", "NUE", "PPG", "PEP", "PNR", "PG", "SHW", "SWK", "SYY", "TROW", "TGT", "VFC", "WMT", "WBA"]
        @basic_url = 'http://dev.markitondemand.com/MODApis/Api/v2/Quote/json?symbol='
        @sp_data_hash = {}
        Quote.all.each do |quote|
          if quote.best_rate == nil
            quote.best_rate = quote.idealness
          end

          if quote.day_change == nil
            quote.day_change = 0
          end

          sleep 5
          puts "now doing symbol #{quote.symbol}"
          #get JSON
          new_url = @basic_url + quote.symbol
          response = HTTParty.get(new_url)
          parsed_resp = JSON.parse(response)

          #get last dividend
          a = Mechanize.new
          sleep 1
          a = a.get("http://www.nasdaq.com/symbol/#{quote.symbol}/dividend-history")
          quarterly_dividend = a.search('span#quotes_content_left_dividendhistoryGrid_CashAmount_0').text.to_f

          dividend_percentage = quarterly_dividend / parsed_resp["LastPrice"]
          @sp_data_hash[quote.symbol] = dividend_percentage

          puts "We now have symbol #{quote.symbol} with percentage return of: #{@sp_data_hash[quote.symbol].round(3) * 400}%"

          quote.idealness = (@sp_data_hash[quote.symbol] * 400).round(3)

          if quote.updated_at == Date.yesterday || quote.yesterday_value == nil
            quote.yesterday_value = quote.idealness
          end

          quote.day_change = (quote.idealness - quote.yesterday_value).round(3)

          if quote.idealness > quote.best_rate
            quote.best_rate = quote.idealness
          end

          quote.save
        end
      rescue => e
        puts "Currently have an error of #{e.try(:message)}"
        puts "Take ten"
        sleep 300
      end
      #
      # @sp_data_hash.each do |key, value|
      #   new_quote = Quote.new
      #   new_quote.symbol = key
      #   new_quote.idealness = (value * 400).round(3)
      #   new_quote.save
      # end
    sleep 300
  end
end
