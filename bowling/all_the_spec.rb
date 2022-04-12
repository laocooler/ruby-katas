describe Game do
  describe "#score" do
    it "all 0's scores 0" do
      rolls = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
      rolls.each { |pins| subject.roll(pins) }
      expect(subject.score).to eq 0
    end

    it "scores a game with no strikes or spares" do
      rolls = [3, 6, 3, 6, 3, 6, 3, 6, 3, 6, 3, 6, 3, 6, 3, 6, 3, 6, 3, 6]
      rolls.each { |pins| subject.roll(pins) }
      expect(subject.score).to eq 90
    end

    describe "spares" do
      it "adds the next ball on to a spares score" do
        rolls = [6, 4, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        rolls.each { |pins| subject.roll(pins) }
        expect(subject.score).to eq 16
      end

      it "scores consecutive spares" do
        rolls = [5, 5, 3, 7, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        rolls.each { |pins| subject.roll(pins) }
        expect(subject.score).to eq 31
      end

      it "scores 10 points for a spare followed by a 0" do
        rolls = [6, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        rolls.each { |pins| subject.roll(pins) }
        expect(subject.score).to eq 10
      end
    end

    describe "strikes" do
      it "lets a strike earns just 10 points in a single roll game" do
        rolls = [10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        rolls.each { |pins| subject.roll(pins) }
        expect(subject.score).to eq 10
      end

      it "lets a strike score the 2 next rolls as a bonus" do
        rolls = [10, 5, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        rolls.each { |pins| subject.roll(pins) }
        expect(subject.score).to eq 26
      end


      it "lets consecutive strikes get the 2 roll bonus" do
        rolls = [10, 10, 10, 5, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        rolls.each { |pins| subject.roll(pins) }
        expect(subject.score).to eq 81
      end
    end

    xdescribe "bonus rolls" do
      it "scores a spare in the last frame gets one bonus roll that is counted once" do
        rolls = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 3, 7]
        rolls.each { |pins| subject.roll(pins) }
        expect(subject.score).to eq 17
      end

      it "scores a strike in the last frame gets two roll bonus that is counted once" do
        rolls = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10, 7, 1]
        rolls.each { |pins| subject.roll(pins) }
        expect(subject.score).to eq 18
      end

      it "rolling a spare with the 2 roll bonus does not give a bonus roll" do
        rolls = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10, 7, 3]
        rolls.each { |pins| subject.roll(pins) }
        expect(subject.score).to eq 20
      end

      it "rolling strikes with the 2 roll bonus does not give more bonus rolls" do
        rolls = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10, 10, 10]
        rolls.each { |pins| subject.roll(pins) }
        expect(subject.score).to eq 30
      end

      it "rolling a strike with the one roll bonus for a spare in the last frame does not get a bonus" do
        rolls = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 3, 10]
        rolls.each { |pins| subject.roll(pins) }
        expect(subject.score).to eq 20
      end

      it "gives a score of 300 for the perfect game of all strikes" do
        rolls = [10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10]
        rolls.each { |pins| subject.roll(pins) }
        expect(subject.score).to eq 300
      end
    end

    xdescribe "error handling" do
      it "does not allow negative rolls" do
        expect { subject.roll(-1) }.to raise_error(Game::BowlingError)
      end

      it "does not allow rolls over 10 points" do
        expect { subject.roll(11) }.to raise_error(Game::BowlingError)
      end

      it "does not allow 2 rolls in a frame to be over 10 points" do
        subject.roll(5)
        expect { subject.roll(6) }.to raise_error(Game::BowlingError)
      end

      it "does not allow a roll after a strike in the last game to more than 10 points" do
        rolls = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10]
        rolls.each { |pins| subject.roll(pins) }
        expect { subject.roll(11) }.to raise_error(Game::BowlingError)
      end

      it "does not allow the bonus rolls after a strike to be more than 10 points combined" do
        rolls = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10, 5]
        rolls.each { |pins| subject.roll(pins) }
        expect { subject.roll(6) }.to raise_error(Game::BowlingError)
      end

      it "does allow the bonus rolls after a strike to be more than 10 points combined if one is a strike" do
        rolls = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10, 10, 6]
        rolls.each { |pins| subject.roll(pins) }
        expect(subject.score).to eq 26
      end

      it "does not allow the last bonus roll after a strike to be a strike if the first is not" do
        rolls = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10, 6]
        rolls.each { |pins| subject.roll(pins) }
        expect { subject.roll(10) }.to raise_error(Game::BowlingError)
      end

      it "does not allow the second bonus roll after a strike to be more than 10 points" do
        rolls = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10, 10]
        rolls.each { |pins| subject.roll(pins) }
        expect { subject.roll(11) }.to raise_error(Game::BowlingError)
      end

      it "does not allow an unstarted game to be scored" do
        expect { subject.score }.to raise_error(Game::BowlingError)
      end

      it "does not allow an incomplete game to be scored" do
        rolls = [0, 0]
        rolls.each { |pins| subject.roll(pins) }
        expect { subject.score }.to raise_error(Game::BowlingError)
      end

      it "does not allow you to roll if the game already has 10 frames" do
        rolls = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        rolls.each { |pins| subject.roll(pins) }
        expect { subject.roll(0) }.to raise_error(Game::BowlingError)
      end

      it "does not let you score if neither of the bonus rolls for a last strike have no been rolled" do
        rolls = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10]
        rolls.each { |pins| subject.roll(pins) }
        expect { subject.score }.to raise_error(Game::BowlingError)
      end

      it "does not let you score unless the bonus rolls for a last strike have both been rolled" do
        rolls = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10, 10]
        rolls.each { |pins| subject.roll(pins) }
        expect { subject.score }.to raise_error(Game::BowlingError)
      end

      it "does not let you score unless the bonus roll for a spare have been rolled" do
        rolls = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 3]
        rolls.each { |pins| subject.roll(pins) }
        expect { subject.score }.to raise_error(Game::BowlingError)
      end

      it "does not let you roll after the bonus roll for a spare" do
        rolls = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 3, 2]
        rolls.each { |pins| subject.roll(pins) }
        expect { subject.roll(0) }.to raise_error(Game::BowlingError)
      end

      it "does not let you roll after the bonus rolls for a strike" do
        rolls = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10, 3, 2]
        rolls.each { |pins| subject.roll(pins) }
        expect { subject.roll(0) }.to raise_error(Game::BowlingError)
      end
    end
  end
end