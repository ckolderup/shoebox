DEBUG = true
DOT_SIZE_MIN = 40
DOT_SIZE_MAX = 60
DOT_COUNT_MAX = 4
DOT_SPEED_MIN = 0
DOT_SPEED_MAX = 20

require 'dot'

Shoes.app :height => 640, :width => 640 do
  
  def addDot
      vel = [(DOT_SPEED_MIN..DOT_SPEED_MAX).to_a.sample, (DOT_SPEED_MIN..DOT_SPEED_MAX).to_a.sample]
      pos = [(0..self.width).to_a.sample, (0..self.height).to_a.sample]
      fill self.send(@colors.sample)
      @dots << Dot.new(self, pos, :size => (DOT_SIZE_MIN..DOT_SIZE_MAX).to_a.sample, :vel => vel)
      @dying << @dots[0] if (@dots.size > DOT_COUNT_MAX)
  end
  
  background black
  @colors = [ "chartreuse", "cornflowerblue", 
              "darkorange", "darkmagenta",
              "deeppink", "indigo",
              "ghostwhite", "maroon" ]
  @dots = []
  @dying = []
  
  addDot

  animate(30) do |i|
    @dots.each do |dot|
      dot.check_collisions @dots
    end

    @dots.each do |dot|
      dot.velocitize
      dot.move
    end 

    @dying.each do |dot|
      if (dot.die_slowly == "dead") then
        @dying.delete(dot)
        @dots.delete(dot)
      end
    end 

  end

  keypress do |k|
    if (k == 'a') then
      addDot
    end
  end

end

