# 💡 improvements: validate to ensure that guess contains exactly 4 elements

module Comms

    def intro
        puts"Welcome to Mastermind! Let's start of with your name: \n" 
    end

    def menu
        puts "-----------------------------------------------------------"
        puts "-                         Menu                            -"
        puts "-----------------------------------------------------------"
        puts "  Enter code using the first 3 letters of the color."
        puts "                      RED = RED 🔴"
        puts "                      GRE = GREEN 🟢"
        puts "                      YEL = YELLOW 🟡"
        puts "                      BLU = BLUE 🔵"
        puts "                      BLA = BLACK ⚫"
        puts "                      ORA = ORANGE 🟠"
        puts ""
        puts "  Example: 🔴 🟡 🟠 ⚫ = RED YEL ORA BLA"
        puts "  👉 NOTE: there are NO duplicates. The colors are unique❗❗"
        puts "-----------------------------------------------------------"
        puts "-----------------------------------------------------------"
        puts "-                    🧠 MASTERMIND 🧠                     -"   
        puts "-----------------------------------------------------------"
    end

    def prompt_the_pick
        puts "Please enter your choice ="
    end

    def address_idiot
        puts "Please enter a valid submission. Follow the guidelines in the Menu on how to submit bozo 🤡"          
    end

    def outro
        puts "What a game! Re-run the script to play again 🔁"
    end

    def understanding_eval
        puts "⚪ means that you have one color that's in the right position and the right color"
        puts "⚫ means that you have one color that's in the wrong position but still a correct selection"
        puts "❌ means that the color is not in the code"
    end

end

class GameFlow

    include Comms
    def active_game(bs, p)
        player_won = false
        game_running = true
        rounds_played = 0 
        bs.generate_code #code generated and stored ONCE
        while game_running
            menu
            bs.unknown_code
            bs.outcomes
            understanding_eval
            p.capture_guess
            if p.selections == BoardState.what_da_code_is #if guess == code
                game_running = false 
                player_won = true
            end
            break unless game_running 
            bs.evaluate_the_guess(p.selections, rounds_played)
            rounds_played += 1
            game_running = false if rounds_played == 8 #ends game if max rounds reached
        end
        menu
        bs.known_code
        bs.evaluate_the_guess(p.selections, rounds_played)
        bs.outcomes
        if player_won
            puts "You WON! you stud!"
        else 
            puts "Sorry buddy! Better luck next time 😥"
        end
    end
    
end
 
class BoardState #this simply controls the state of the board
    include Comms

    @@hash_of_colors =
    {
        "RED" => 1,
        "GRE" => 2, 
        "YEL" => 3, 
        "BLU" => 4,
        "BLA" => 5, 
        "ORA" => 6
    }

    @@reverse_hash_of_colors =
    {
        1 => "🔴", 
        2 => "🟢", 
        3 => "🟡", 
        4 => "🔵",
        5 => "⚫",
        6 => "🟠"
    }

    @@eval_table = 
    {
        1 => "⚪", 
        2 => "⚫", 
        3 => "❌"
    }
    
    @@unevaluated_str_template =
    "-----------------------------------------------------------",
    " - - | \n ",
    " - - |     -       -       -       -",
    "-----------------------------------------------------------"

    @@hidden_code = 
    "-----------------------------------------------------------", 
    "| 🔐 |    UNK    UNK    UNK    UNK",
    "-----------------------------------------------------------"

    @@all_the_outcomes =
    [
      @@unevaluated_str_template,
      @@unevaluated_str_template,
      @@unevaluated_str_template,
      @@unevaluated_str_template,
      @@unevaluated_str_template,
      @@unevaluated_str_template,
      @@unevaluated_str_template,
      @@unevaluated_str_template,
      @@unevaluated_str_template,
    ]

    def self.run_the_hash
        @@hash_of_colors
    end

    def outcomes 
        puts @@all_the_outcomes
    end

    def known_code
        puts "-----------------------------------------------------------" 
        puts "| 🔓 💥 |    #{@@reverse_hash_of_colors[@@secret_code[0]]}    #{@@reverse_hash_of_colors[@@secret_code[1]]}    #{@@reverse_hash_of_colors[@@secret_code[2]]}    #{@@reverse_hash_of_colors[@@secret_code[3]]}"
        puts "-----------------------------------------------------------"
    end
    
    def unknown_code
        puts @@hidden_code
    end
    
    def generate_code
        #this is where/how we determine the 'secret code'
        colors = [1,2,3,4,5,6]
        code = four_random_nums(colors)
        @@secret_code = code
    end

    def evaluate_the_guess(guess, round)
        ordered_eval = []
        i = 0
        while i < 4
          element_inside = false
          at_the_right_idx = false  
          element_inside = true if @@secret_code.include?(guess[i])
          if element_inside
            at_the_right_idx = true if guess[i] == @@secret_code[i]
          end
        ordered_eval << collate_evaluation(element_inside, at_the_right_idx)
        i += 1
        end
        @@unordered_eval = four_random_nums(ordered_eval)
        modify_outcome(@@unordered_eval, guess, round)
    end

    def collate_evaluation(ele, idx)
        return 1 if ele && idx
        return 2 if ele 
        return 3
    end

    def modify_outcome(arr, guess, round)
        @@all_the_outcomes[round] =
        "-----------------------------------------------------------",
        " #{@@eval_table[arr[0]]} #{@@eval_table[arr[1]]} | \n ",
        " #{@@eval_table[arr[2]]} #{@@eval_table[arr[3]]} |     #{@@reverse_hash_of_colors[guess[0]]}    #{@@reverse_hash_of_colors[guess[1]]}    #{@@reverse_hash_of_colors[guess[2]]}    #{@@reverse_hash_of_colors[guess[3]]}",
        "-----------------------------------------------------------" 
    end

    def four_random_nums(list)
        random_nums = []
        4.times do
            random = rand(0...list.length) 
            random_nums << list.delete_at(random)
        end
        random_nums    
    end

    def self.what_da_code_is
        @@secret_code
    end

end

class Player #this controls the player
    include Comms
    attr_accessor :name, :selections

    def initialize(name)
        @name = name 
        @selections
    end

    def capture_guess #✅
        #capturing the user's colors
        valid_submission = false
        until valid_submission
            prompt_the_pick
            picks = gets.chomp
            valid_submission = sanitize_selection(picks)
            address_idiot unless valid_submission
        end
        convert_to_hash_values(selections)
    end

    def sanitize_selection(picks) #✅
        all_clean = false 
        picks.upcase!
        picks = picks.split
        all_clean = picks.all? {|color| BoardState.run_the_hash.include?(color)}
        self.selections = picks if all_clean
    end

    def convert_to_hash_values(selections) #✅
        # {
        #     "RED" => 1,
        #     "GRE" => 2, 
        #     "YEL" => 3, 
        #     "BLU" => 4,
        #     "BLA" => 5, 
        #     "ORA" => 6
        # }
        selections.map! {|x| BoardState.run_the_hash[x]}
    end

end

#--'booting' up the game
gf = GameFlow.new()
bs = BoardState.new()

#--intro + player prompt
gf.intro
puts "What's your name?"
p = Player.new(gets.chomp)

#--start 
bs.generate_code
gf.active_game(bs, p)

#--ending
gf.outro