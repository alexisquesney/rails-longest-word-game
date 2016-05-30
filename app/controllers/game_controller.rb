require 'open-uri'
require 'json'

class GameController < ApplicationController
  def game
    session[:grid] = generate_grid(9)
  end

  def score
    # @included = included?(params[:answer], session[:grid])
    @result_det = run_game(params[:answer], session[:grid], session[:start_time])
    @result = score_and_message(params[:answer], get_translation(params[:answer]), session[:grid], session[:time])
  end

def generate_grid(grid_size)
  session[:start_time] = Time.now.to_i
  Array.new(grid_size) { ('A'..'Z').to_a[rand(26)] }
end


def included?(guess, grid)
  the_grid = grid.clone
  guess.chars.each do |letter|
    the_grid.delete_at(the_grid.index(letter)) if the_grid.include?(letter)
  end
  grid.size == guess.size + the_grid.size
end

def compute_score(attempt, time_taken)
  (time_taken > 60.0) ? 0 : attempt.size * (1.0 - time_taken / 60.0)
end

def run_game(attempt, grid, start_time)
  result_det = { time: session[:time] = (Time.now.to_i - start_time) }

  result_det[:translation] = get_translation(attempt)
  result_det[:score], result_det[:message] = score_and_message(
    attempt, result_det[:translation], grid, result_det[:time])
  result_det
end

def score_and_message(attempt, translation, grid, time)
  if translation
    if included?(attempt.upcase, grid)
      score = compute_score(attempt, time)
      [score, "well done"]
    else
      [0, "not in the grid"]
    end
  else
    [0, "not an english word"]
  end
end

def get_translation(word)
  response = open("http://api.wordreference.com/0.8/80143/json/enfr/#{word.downcase}")
  json = JSON.parse(response.read.to_s)
  json['term0']['PrincipalTranslations']['0']['FirstTranslation']['term'] unless json["Error"]
end

end
