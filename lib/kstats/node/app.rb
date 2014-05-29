require 'sinatra'

module Kstats
  module Node
    class App < Sinatra::Base
      set :port, Kstats::Node::Config['server.port', 4567].to_i
      set :bind, Kstats::Node::Config['server.bind', '0.0.0.0']

      get '/probes/list' do
        Kstats::Node::Probe.list.to_json
      end

      #Display data for daily infos
      get '/probe/:id/:target' do
        now = Time.now

        case params[:target]
        when 'tick'
          start = now - (60*60*24)
        when 'weekly'
          start = now - 7*(60*60*24)
        when 'monthly'
          start = now - 30*(60*60*24)
        when 'yearly'
          start = now - 365*(60*60*24)
        else
          return 403
        end


        data =Kstats::Node::Database.db.execute(
          "SELECT probe_key, date, probe_value FROM probe_data WHERE period_type=? AND probe_id = ? AND date >= ? ORDER BY date ASC",
          params[:target],
          params[:id],
          start.to_s
        )

        datas = {}
        data.each do |record|
          key, date, value = record
          datas[key] ||= []
          datas[key] << [Time.parse(date), value]
        end

        datas.each do |key, value|
          datas[key] =   Kstats::Node::Helper.generate_array(value, start, (now-start)/60, 288)
        end

        {
          start_at: start,
          format: Kstats::Node::Probe.get_format(params[:id]),
          data: datas
        }.to_json
      end
    end
  end
end

