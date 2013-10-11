class Card
  attr_accessor :suit, :value

  def initialize(s,v)
    @suit = s
    @value = v
  end
end

class Deck
  attr_accessor :deck

  def initialize
    @deck = []
    ['Hearts', 'Spades', 'Clubs', 'Diamonds'].each do |suit|
      ['2', '3', '4', '5', '6', '7', '8', '9', '10','Ace', 'King', 'Queen', 'Jack'].each do |value|
        @deck << Card.new(suit, value)
        #puts "Test"
      end
    end
    scramble!
  end
  
  def scramble!
    deck.shuffle!
  end

  def deal_one 
    deck.pop
  end

  def size
    deck.size
  end
end

module Hand
  def show_hand
    puts "------#{name}'s Hand ------"
    cards.each do|card|
      puts "=> #{card.value}  of #{card.suit}"
    end

    if total[1] != 0
      puts "=> Your two totals are: #{total[0]} and #{total[1]}"
    else
      puts "=> Your total is: #{total[0]}"
    #  best_total = total[0]
    end
  end

  def total
    face_values = cards.map{|card| card.value}

    sum1 = 0
    sum2 = 0

    face_values.each do |val|
      if val == "Ace"
        sum1 += 1
      else
        sum1 += (val.to_i == 0 ? 10 : val.to_i)    
      end
    end

    if face_values.include? "Ace"
       sum2 = sum1 + 10
    end

    return sum1, sum2
  end

  def add_card(new_card)
    cards << new_card
  end

  def is_busted?
   (total[0] > Blackjack::BLACKJACK_AMOUNT) && (total[1] > Blackjack::BLACKJACK_AMOUNT)
  end
end

class Player
  include Hand

  attr_accessor :name, :cards, :best_total

  def initialize(n)
    @name = n
    @cards = []
    @best_total = 0
  end

  def show_flop
    show_hand
  end
end

class Dealer
  include Hand

  attr_accessor :name, :cards, :best_total

  def initialize
    @name = "Dealer"
    @cards = []
    @best_total = 0
  end
  
  def show_flop
    puts "----Dealer's Hand ------"
    puts "=> First card is hidden"
    puts "=> Second card is #{cards[1].value} of #{cards[1].suit}"
  end

end

class Blackjack
  
  attr_accessor :player, :dealer, :gdeck

  BLACKJACK_AMOUNT = 21
  DEALER_HIT_MIN = 17
  
  def initialize
    @player = Player.new("Player1")
    @dealer = Dealer.new
    @gdeck = Deck.new
    set_player_name
  end

  def set_player_name
    puts "What's your name?"
    player.name = gets.chomp.capitalize
  end




  def deal_cards
    player.add_card(gdeck.deal_one)
    dealer.add_card(gdeck.deal_one)
    player.add_card(gdeck.deal_one)
    dealer.add_card(gdeck.deal_one)
  end

  def show_flop
    player.show_flop
    dealer.show_flop
  end
  
  def blackjack_or_bust?(player_or_dealer)
    if (player_or_dealer.total[0] == BLACKJACK_AMOUNT) || (player_or_dealer.total[1] == BLACKJACK_AMOUNT)
      if player_or_dealer.is_a?(Dealer)
        puts "Sorry, dealer hit blackjack. #{player.name} loses."
      else
        puts "Congratulations, you hit blackjack! #{player.name} wins!"
      end
      play_again?
    elsif player_or_dealer.is_busted?
      if player_or_dealer.is_a?(Dealer)
        puts "Congratulations, dealer busted. #{player.name} wins!"
      else 
        puts "Sorry, #{player.name} busted. #{player.name} loses."
      end
      play_again?

    end
  end

  def say
    puts 'Would you like to hit or stay?'
    answer = gets.chomp.downcase
    return answer
  end

  def player_goes
    blackjack_or_bust?(player)

    if player.total[1] != 0
        if (player.total[0] < player.total[1]) && (player.total[1] < 21)
          player.best_total = player.total[1]
        else
          player.best_total = player.total[0]
        end
    else
      player.best_total = player.total[0]

    end
    
    while say == "hit"
      new_card = gdeck.deal_one
      puts "Dealing card to #{player.name}: #{new_card.value} of #{new_card.suit}"
      player.add_card(new_card)
      if player.total[1] != 0
        puts "=> Your two totals are: #{player.total[0]} and #{player.total[1]}"
        blackjack_or_bust?(player)
        if (player.total[0] < player.total[1]) && (player.total[1] < 21)
          player.best_total = player.total[1]
        else
          player.best_total = player.total[0]
        end
      else
        puts "=> Your total is: #{player.total[0]}"
        blackjack_or_bust?(player)
        player.best_total = player.total[0]
      end
     # blackjack_or_bust?(player)
    end
    
    
    puts "#{player.name} stays at #{player.best_total}."

  end

  def dealer_goes
    blackjack_or_bust?(dealer)
    if dealer.total[1] != 0
        puts "=> Dealer totals are: #{dealer.total[0]} and #{dealer.total[1]}"
        if (dealer.total[1] < 21)
          dealer.best_total = dealer.total[1]
        else
          dealer.best_total = dealer.total[0]
        end 
      else
        puts "=> Dealer's total is: #{dealer.total[0]}"
        dealer.best_total = dealer.total[0]
      end
    
    while dealer.best_total < DEALER_HIT_MIN
      new_card = gdeck.deal_one
      puts "Dealing card to dealer: #{new_card.value} of #{new_card.suit}"
      dealer.add_card(new_card)
      if dealer.total[1] != 0
        puts "=> Dealer's totals are: #{dealer.total[0]} and #{dealer.total[1]}"
        blackjack_or_bust?(dealer)
        if (dealer.total[1] < 21)
          dealer.best_total = dealer.total[1]
        else
          dealer.best_total = dealer.total[0]
        end 
      else
        puts "=> Dealer's total is: #{dealer.total[0]}"
        blackjack_or_bust?(dealer)
        dealer.best_total = dealer.total[0]
      end
    #  blackjack_or_bust?(dealer)

    end 

    puts "Dealer stays at #{dealer.best_total}"

  end

  def who_won?
    if dealer.best_total == player.best_total
      puts "It's a push"
    elsif dealer.best_total > 21
      puts "#{player.name} wins!"
    elsif dealer.best_total < player.best_total
      puts "#{player.name} wins!"
    elsif (dealer.best_total <= 21) && (dealer.best_total > player.best_total)
      puts 'House wins'
    end
  end
  
  def play_again?
    puts "#{player.name} would you like to play again? "
    if gets.chomp.downcase == 'yes'
      puts "Starting new game"
      puts " "
      gdeck = Deck.new
      player.cards = []
      dealer.cards = []
      run
    else
      puts "Goodbye"
      exit
    end
  end

  def run
    deal_cards
    show_flop
    player_goes
    dealer_goes
    who_won?
    play_again?
  end
end


Blackjack.new.run

