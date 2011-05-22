DEBUG = true
DOT_SIZE_MIN = 20
DOT_SIZE_MAX = 60
DOT_COUNT_MAX = 4
DOT_SPEED_MIN = -20
DOT_SPEED_MAX = 20

require 'lib/dot'

Shoes.app :height => 640, :width => 640, :title => "Dots!" do
  
  def addDot
      return unless @dying.empty?
      
      fill self.send(@colors.sample)
      size = (DOT_SIZE_MIN..DOT_SIZE_MAX).to_a.sample
      vel = [(DOT_SPEED_MIN..DOT_SPEED_MAX).to_a.sample, 
             (DOT_SPEED_MIN..DOT_SPEED_MAX).to_a.sample]
      pos = [(0..self.width-size).to_a.sample,
             (0..self.height-size).to_a.sample]
      new_dot = Dot.new(self, pos, 
                        :size => (DOT_SIZE_MIN..DOT_SIZE_MAX).to_a.sample,
                        :v => vel) 

      while unsafe_dot?(new_dot, @dots) do
        new_dot.pos = [(0..self.width).to_a.sample,
                       (0..self.height).to_a.sample] 
      end
     
      @dots << new_dot
      @dying << @dots[0] if (@dots.size > DOT_COUNT_MAX)
  end

  def unsafe_dot?(new_dot, dots)
      dots.each do |other| 
        return true if new_dot.overlap?(other)
      end
      return false
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

