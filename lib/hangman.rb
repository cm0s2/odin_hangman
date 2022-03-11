# frozen_string_literal: true

require 'pry-byebug'
require 'yaml'

# Hangman class
class Hangman
  MAX_NUM_OF_GUESSES = 8
  GAMESAVE_FILENAME = 'gamesave.yaml'
  def initialize
    if gamesave_available? && player_want_to_load_save?
      load_game
    else
      @word = random_word
      @used_letters = []
      @guessed_words = []
    end
  end

  def play
    puts 'Make a guess by typing a letter or an entire word'
    puts 'Save and quit by pressing enter while not entering any value'
    until game_over?
      print_positions
      show_result
      make_guess
      show_result if game_over?
    end
    delete_gamesave
  end

  private

  def gamesave_available?
    File.exist?(GAMESAVE_FILENAME)
  end

  def player_want_to_load_save?
    choice = ''
    until %w[y n].include?(choice)
      print 'Do you want to load your saved progress? y/n '
      choice = gets.chomp
    end
    choice == 'y'
  end

  def to_yaml
    YAML.dump({
                word: @word,
                used_letters: @used_letters,
                guessed_words: @guessed_words
              })
  end

  def save_and_exit
    save_game
    puts 'Exiting game'
    exit
  end

  def save_game
    File.open(GAMESAVE_FILENAME, 'w') { |file| file.write(to_yaml) }
    puts 'Game saved'
  end

  def load_game
    data = YAML.load(File.read(GAMESAVE_FILENAME))
    @word = data[:word]
    @used_letters = data[:used_letters]
    @guessed_words = data[:guessed_words]
  end

  def delete_gamesave
    File.delete(GAMESAVE_FILENAME) if File.exist?(GAMESAVE_FILENAME)
  end

  def game_over?
    word_found? || out_of_guesses?
  end

  def out_of_guesses?
    return true if num_of_guesses >= MAX_NUM_OF_GUESSES
  end

  def word_found?
    return false unless guessed_all_letters? || guessed_exact_word?

    true
  end

  def guessed_all_letters?
    @word.split('').each do |letter|
      return false unless @used_letters.include?(letter)
    end
    true
  end

  def guessed_exact_word?
    @guessed_words.last == @word
  end

  def num_of_guesses
    @used_letters.length + @guessed_words.length
  end

  def show_result
    if word_found?
      puts "You won! The correct word was #{@word}"
    elsif out_of_guesses?
      puts "You lost. The correct word was #{@word}"
    else
      puts "Guesses left: #{8 - num_of_guesses}. Used letters: #{@used_letters.join(', ')}"
    end
  end

  def print_positions
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
    guess = nil
    until valid_guess?(guess)
      print 'Make a guess: '
      guess = gets.chomp.downcase
    end
    if guess.length == 1
      @used_letters.push(guess)
    elsif guess.length > 1
      @guessed_words.push(guess)
    elsif guess.empty?
      save_and_exit
    end
  end

  def valid_guess?(guess)
    return false if guess.nil?

    possible_letter?(guess) || guess.length > 1 || guess.empty?
  end

  def possible_letter?(guess)
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
