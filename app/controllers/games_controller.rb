require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @letters = (0...10).map { ('A'..'Z').to_a[rand(26)] }
  end

  def score
    grid = params[:letter_grid].split(' ')
    @result = run_game(params[:word], grid)
  end

  def attempt_in_grid?(attempt, grid)
    # create an hash from the grid
    grid_hash = Hash.new(0)
    grid.each { |chr_grid| grid_hash [chr_grid] += 1 }

    # check each letter attempt according to the grid
    attempt.each_char do |chr_attempt|
      if grid_hash.key?(chr_attempt)
        grid_hash [chr_attempt] -= 1
        return false if grid_hash[chr_attempt].negative?
      else return false
      end
    end
    return true
  end

  def run_game(attempt, grid)
    # TODO: runs the game and return detailed hash of result

    # check is the word exist and catch API message
    url = "https://wagon-dictionary.herokuapp.com/#{attempt}"
    api_return = open(url).read
    api_return_hash = JSON.parse(api_return)

    return { score: 0, message: "Lost, not an english word" } unless api_return_hash['found']

    if attempt_in_grid?(attempt.upcase, grid)
      score = attempt.length * 10
      return { score: score, message: "Well done !" }
    else
      return { score: 0, message: "Sorry you loose, it's not in the grid" }
    end
  end
end
