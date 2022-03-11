# frozen_string_literal: true
require 'pry-byebug'

# Hangman class
class Hangman
  NUM_OF_GUESSES = 8
  def initialize
    @word = random_word
    @used_letters = []
    p @word
  end

  def play
    until game_over?
      show_result
      make_guess
    end
  end

  private

  def game_over?
    word_found? || out_of_guesses?
  end

  def out_of_guesses?
    return true if @used_letters.length >= NUM_OF_GUESSES
  end

  def word_found?
    @word.split('').each do |letter|
      return false unless @used_letters.include?(letter)
    end
    puts 'You won!'
    true
  end

  def show_result
    print "Guesses left: #{8 - @used_letters.length}\t\t"
    @word.split('').each do |letter|
      if @used_letters.include?(letter)
        print "#{letter} "
      else
        print '_ '
      end
    end
    puts
  end

  def make_guess
    guess = ''
    until valid_guess?(guess)
      print 'Make a guess: '
      guess = gets.chomp.downcase
    end
    @used_letters.push(guess)
  end

  def valid_guess?(guess)
    # binding.pry
    guess.length == 1 && guess.match?(/[[:alpha:]]/) && !@used_letters.include?(guess)
  end

  def load_wordlist
    wordlist = File.readlines('google-10000-english-no-swears.txt', chomp: true)
    wordlist.filter { |word| word.length >= 5 && word.length <= 12 }
  end

  def random_word
    load_wordlist.sample
  end
end

Hangman.new.play
