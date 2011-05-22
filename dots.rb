DEBUG = true
DOT_SIZE_MIN = 40
DOT_SIZE_MAX = 60
DOT_COUNT_MAX = 4
DOT_SPEED_MIN = 0
DOT_SPEED_MAX = 20

class Point
  attr_accessor :x, :y
  def initialize(x, y)
    @x = x
    @y = y
  end

  def to_s
    "(#{@x}, #{@y})"
  end
end

class Dot
  attr_accessor :pos, :size, :mass, :v

  def initialize(app, pos, opt = {})
    @app = app
    @pos = Point.new(*pos)
    
    @v = Point.new(*opt[:vel]) || Point.new(0.0, 0.0)
    @fv = Point.new(@v.x, @v.y)
    @size = opt[:size] || 25
    @mass = opt[:mass] || 1
    @name = opt[:name] || "unnamed" #for debugging purposes
    if (!opt[:hidden]) then
      @rect = @app.rect :top => @pos.y, :left => @pos.x, :width => @size
    end
  end

  def die_slowly
    @rect.height -= 1
    @rect.width -= 1

    if @rect.width == 0 then
      @rect.remove
    end
    return @rect.width == 0 ? "dead" : "dying"
  end

  def move
    @pos.x += @v.x * @mass
    @pos.y += @v.y * @mass
    @rect.move @pos.x, @pos.y
  end

  def check_collisions(others)
    contact = [] 
    others.each do |other|
    contact << other if other != self and will_hit?(other)
    end

    contact.each do |other|
     collide(other)
    end

    if hit_wall? #TODO: refactor, there's some duplicate logic in here
     hit_stationary
    end
  end

  def hit_wall?
    (@pos.x         <= 0           and @fv.x <  0) or
    (@pos.x + @size >= @app.width  and @fv.x >= 0) or
    (@pos.y         <= 0           and @fv.y <  0) or 
    (@pos.y + @size >= @app.height and @fv.y >= 0)
  end

  def hit_stationary
    @fv.x = -@fv.x if (@pos.x         <= 0          and @fv.x <  0) or
                      (@pos.x + @size >= @app.width and @fv.x >= 0)

    @fv.y = -@fv.y if (@pos.y         <= 0           and @fv.y <  0) or
                      (@pos.y + @size >= @app.height and @fv.y >= 0)
  end

  def collide(other)
      mco1 = (@mass - other.mass) / (@mass + other.mass)
      mco2 = 2*other.mass / (@mass + other.mass)

      @fv.x = mco1 * @v.x + mco2 * other.v.x
      @fv.y = mco1 * @v.y + mco2 * other.v.y
  end

  def pos_at(step)
    Point.new(@pos.x + step*@v.x, @pos.y + step*@v.y)
  end

  def will_hit?(other)
    (0.1..1.0).step(0.3).each do |i|
      fpos = self.pos_at(i)
      ofpos = other.pos_at(i)
      return true if fpos.x + @size >= ofpos.x              and
                     fpos.x         <= ofpos.x + other.size and
                     fpos.y + @size >  ofpos.y              and
                     fpos.y         <= ofpos.y + other.size
    end
    return false
  end
  
  def velocitize
    if DEBUG && (@v.x != @fv.x or @v.y != @fv.y) then
      Shoes.debug "#{@name} from #{@v.to_s} to #{@fv.to_s}"
    end
    @v.x = @fv.x
    @v.y = @fv.y
  end

end

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

