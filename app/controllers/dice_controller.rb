# frozen_string_literal: true

# Roll a dice !
class DiceController < ApplicationController
  def index
    @dice_roll = rand(1..6).to_s
    logger.info "roll: #{@dice_roll}"
  end
end
