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
    Shoes.debug "HELP MEEEEE"
    @app = app
    @pos = Point.new(*pos)
    @v = opt[:v] ? Point.new(*opt[:v]) : Point.new(0.0, 0.0)
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

  def pos=(arr)
    @pos = Point.new(*arr)
    @rect.move @pos.x, @pos.y
  end
  
  def velocitize
    if DEBUG && (@v.x != @fv.x or @v.y != @fv.y) then
      Shoes.debug "#{@name} from #{@v.to_s} to #{@fv.to_s}"
    end
    @v.x = @fv.x
    @v.y = @fv.y
  end

  def move
    velocitize
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

  def overlap?(other, at=0)
    fpos = self.pos_at(at)
    ofpos = other.pos_at(at)
    
    return (fpos.x + @size >= ofpos.x              and
            fpos.x         <= ofpos.x + other.size and
            fpos.y + @size >  ofpos.y              and
            fpos.y         <= ofpos.y + other.size)
  end

  def will_hit?(other)
    (0.1..1.0).step(0.3).each do |i|
      next if !(self.overlap?(other, i))
      return true
    end
    return false
  end
  
end

