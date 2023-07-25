# frozen_string_literal: true
require 'aws-sdk-s3'

# Roll a dice !
class DiceController < ApplicationController
  def index
    @dice_roll = rand(1..6).to_s
    File.write('storage/dice-roll.txt', "roll: #{@dice_roll}")

    s3 = Aws::S3::Client.new(
      region: 'eu-west-1',
      endpoint: 'http://localhost:4566',
      access_key_id: ENV.fetch('AWS_ACCESS_KEY_ID', 'test'),
      secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY', 'test'),
      force_path_style: true
    )

    File.open('storage/dice-roll.txt', 'rb') do |file|
      s3.put_object(bucket: 'dice-app-bucket', key: 'dice-roll-s3.txt', body: file)
    end
    
  end
end
