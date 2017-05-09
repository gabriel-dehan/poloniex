require "poloniex/version"
require 'rest-client'
require 'openssl'
require 'addressable/uri'

module Poloniex
  class Client
    attr_accessor :key, :secret

    def initialize(auth)
      @key    = auth[:key]
      @secret = auth[:secret]
    end

    def get_all_daily_exchange_rates( currency_pair )
      res = get 'returnChartData', currencyPair: currency_pair, period: 86400,  start: 0, :end => Time.now.to_i
    end

    def ticker
      get 'returnTicker'
    end

    def volume
      get 'return24hVolume'
    end

    def order_book( currency_pair )
      get 'returnOrderBook', currencyPair: currency_pair
    end

    def active_loans
      post 'returnActiveLoans'
    end

    def balances
      post 'returnBalances'
    end

    def lending_history( start = 0, end_time = Time.now.to_i )
      post 'returnLendingHistory', start: start, :end => end_time
    end

    def currencies
      get 'returnCurrencies'
    end

    def complete_balances
      post 'returnCompleteBalances'
    end

    def open_orders( currency_pair )
      post 'returnOpenOrders', currencyPair: currency_pair
    end

    def full_trade_history
      post('returnTradeHistory', { currencyPair: "all", start: Time.new("2000-01-01").to_i, :end => Time.now.to_i })
    end

    def trade_history( currency_pair, start = 0, end_time = Time.now.to_i )
      post 'returnTradeHistory', currencyPair: currency_pair, start: start, :end => end_time
    end

    def buy( currency_pair, rate, amount )
      post 'buy', currencyPair: currency_pair, rate: rate, amount: amount
    end

    def sell( currency_pair, rate, amount )
      post 'sell', currencyPair: currency_pair, rate: rate, amount: amount
    end

    def cancel_order( currency_pair, order_number )
      post 'cancelOrder', currencyPair: currency_pair, orderNumber: order_number
    end

    def move_order( order_number, rate )
      post 'moveOrder', orderNumber: order_number, rate: rate
    end

    def withdraw( currency, amount, address )
      post 'widthdraw', currency: currency, amount: amount, address: address
    end

    def available_account_balances
      post 'returnAvailableAccountBalances'
    end

    def tradable_balances
      post 'returnTradableBalances'
    end

    def transfer_balance( currency, amount, from_ccount, to_account )
      post 'transferBalance', currency: currency, amount: amount, fromAccount: from_ccount, toAccount: to_account
    end

    def margin_account_summary
      post 'returnMarginAccountSummary'
    end

    def margin_buy(currency_pair, rate, amount)
      post 'marginBuy', currencyPair: currency_pair, rate: rate, amount: amount
    end

    def margin_sell(currency_pair, rate, amount)
      post 'marginSell', currencyPair: currency_pair, rate: rate, amount: amount
    end

    def deposit_addresses
      post 'returnDepositAddresses'
    end

    def generate_new_address( currency )
      post 'generateNewAddress', currency: currency
    end

    def all_deposits_withdrawls
      post 'returnDepositsWithdrawals', start: Time.new("2000-01-01").to_i, :end => Time.now.to_i
    end

    def deposits_withdrawls( start = 0, end_time = Time.now.to_i )
      post 'returnDepositsWithdrawals', start: start, :end => end_time
    end

    protected

    def resource
      @@resource ||= RestClient::Resource.new( 'https://www.poloniex.com' )
    end

    def get( command, params = {} )
      params[:command] = command
      resource[ 'public' ].get params: params
    end

    def post( command, params = {} )
      params[:command] = command
      params[:nonce]   = (Time.now.to_f * 10000000).to_i
      resource[ 'tradingApi' ].post params, { Key: self.key , Sign: create_sign( params ) }
    end

    def create_sign( data )
      encoded_data = Addressable::URI.form_encode( data )
      OpenSSL::HMAC.hexdigest( 'sha512', self.secret , encoded_data )
    end

  end
end
