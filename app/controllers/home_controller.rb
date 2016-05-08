class HomeController < ApplicationController

  def index
    gmail_username = ENV["gmail_username"]
    gmail_password = ENV["gmail_password"]
    tos_from = "alerts@thinkorswim.com"

    @trades = []
    gmail = Gmail.new(gmail_username, gmail_password)
    tos_mails = gmail.inbox.find(:from => tos_from).last(10)
    tos_mails.each do |mail|
      body_components = mail.body.raw_source.split(',')
      if body_components[1]
        order_message = body_components[1].strip()
        order_components = order_message.split(' ')
        order_components.delete_at(2)
        order_components.delete_at(0)

        if !order_components.last.include?("@")
          order_components.pop
        end

        order_components.each_with_index do |comp, index|
          if comp.first.to_i.to_s == comp.first
            underlying = order_components[index-1]
            if underlying.include?('/')
              # do we even want to do this for futures?
              # underlying.gsub!("/", "$")
            else
              underlying = "$#{underlying}"
            end
            order_components[index-1] = underlying
            break
          end
        end
        formatted_order_message = order_components.join(' ')

        @trades << formatted_order_message
      end
    end
    gmail.logout
    @trades.reverse!
  end

end
