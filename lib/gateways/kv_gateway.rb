require 'mongo'

Mongo::Logger.logger.level = ::Logger::ERROR

class KVGateway
  def initialize
    @client = Mongo::Client.new(['127.0.0.1:27017']).with(database: 'banzai')
  end

  def store(bucket, key, value)
    # puts "storing #{key}"
    @client[:data].update_one({b: bucket, k: key}, {'$set': {v: value}}, upsert: true)
  end

  def delete(bucket, key)
    puts "deleting #{key}"
    @client[:data].delete_one({b: bucket, k: key})
  end

  def fetch(bucket, key)
    doc = @client[:data].find({b: bucket, k: key}).limit(1).to_a[0]
    doc && doc['v']
  end
end
