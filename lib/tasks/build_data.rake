task build_out_symbols: :environment do
  while true do
    puts "Now raking at #{Time.now}...."
      @sp_symbols = ["MMM", "AFL", "ABBV", "ABT", "APD", "ADM", "T", "ADP", "BCR", "BDX", "BMS", "B", "CAH", "CB", "CVX", "CINF", "CTAS", "CLX", "KO", "CL", "ED", "DOV", "ECL", "EMR", "XOM", "BEN", "GPC", "GWW", "HCP", "HRL", "ITW", "JNJ", "KMB", "LEG", "LOW", "MKC", "MCD", "SPGI", "MDT", "NUE", "PPG", "PEP", "PNR", "PG", "SHW", "SWK", "SYY", "TROW", "TGT", "VFC", "WMT", "WBA"]
      @basic_url = 'http://dev.markitondemand.com/MODApis/Api/v2/Quote/json?symbol='
      @sp_data_hash = {}
      Quote.all.each do |quote|
        if quote.best_rate == nil
          quote.best_rate = quote.idealness
        end
        sleep 5
        puts "now doing symbol #{quote.symbol}"
        #get JSON
        new_url = @basic_url + quote.symbol
        response = HTTParty.get(new_url)
        parsed_resp = JSON.parse(response)

        #get last dividend
        a = Mechanize.new
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
