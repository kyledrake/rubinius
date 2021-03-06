#
#   rational.rb -
#       $Release Version: 0.5 $
#       $Revision: 1.7 $
#       $Date: 1999/08/24 12:49:28 $
#       by Keiju ISHITSUKA(SHL Japan Inc.)
#
# Documentation by Kevin Jackson and Gavin Sinclair.
#
# When you <tt>require 'rational'</tt>, all interactions between numbers
# potentially return a rational result.  For example:
#
#   1.quo(2)              # -> 0.5
#   require 'rational'
#   1.quo(2)              # -> Rational(1,2)
#
# See Rational for full documentation.
#


#
# Creates a Rational number (i.e. a fraction).  +a+ and +b+ should be Integers:
#
#   Rational(1,3)           # -> 1/3
#
# Note: trying to construct a Rational with floating point or real values
# produces errors:
#
#   Rational(1.1, 2.3)      # -> NoMethodError
#
def Rational(a, b = 1)
  if a.kind_of?(Rational) && b == 1
    a
  else
    Rational.send :convert, a, b
  end
end

#
# Rational implements a rational class for numbers.
#
# <em>A rational number is a number that can be expressed as a fraction p/q
# where p and q are integers and q != 0.  A rational number p/q is said to have
# numerator p and denominator q.  Numbers that are not rational are called
# irrational numbers.</em> (http://mathworld.wolfram.com/RationalNumber.html)
#
# To create a Rational Number:
#   Rational(a,b)             # -> a/b
#
# Examples:
#   Rational(5,6)             # -> 5/6
#   Rational(5)               # -> 5/1
#
# Rational numbers are reduced to their lowest terms:
#   Rational(6,10)            # -> 3/5
#
# Division by zero is obviously not allowed:
#   Rational(3,0)             # -> ZeroDivisionError
#
class Rational < Numeric

  private_class_method :new

  def self.convert(num, den)
    if num.equal? nil or den.equal? nil
      raise TypeError, "cannot convert nil into Rational"
    end

    case num
    when Integer
      # nothing
    when Float, String, Complex
      num = num.to_r
    end

    case den
    when Integer
      # nothing
    when Float, String, Complex
      den = den.to_r
    end

    if num.kind_of? Integer and den.kind_of? Integer
      return new(num, den)
    end

    if den.equal? 1 and !num.kind_of? Integer
      return Rubinius::Type.coerce_to num, Rational, :to_r
    else
      if num.kind_of? Numeric and den.kind_of? Numeric and
         !(num.kind_of? Integer and den.kind_of? Integer)
        return num / den
      end
    end

    new num, den
  end

  private_class_method :convert

  #
  # This method is actually private.
  #
  def initialize(num, den)
    case num
    when Integer
      # nothing
    when Numeric
      num = num.to_i
    else
      raise TypeError, "numerator is not an Integer"
    end

    case den
    when Integer
      if den == 0
        raise ZeroDivisionError, "divided by 0"
      elsif den < 0
        num = -num
        den = -den
      end

      if den == 1
        @numerator = num
        @denominator = den
        return
      end
    when Numeric
      den = den.to_i
    else
      raise TypeError, "denominator is not an Integer"
    end

    gcd = num.gcd den
    @numerator = num.div gcd
    @denominator = den.div gcd
  end

  #
  # Returns the addition of this value and +a+.
  #
  # Examples:
  #   r = Rational(3,4)      # -> Rational(3,4)
  #   r + 1                  # -> Rational(7,4)
  #   r + 0.5                # -> 1.25
  #
  def + (a)
    if a.kind_of?(Rational)
      num = @numerator * a.denominator
      num_a = a.numerator * @denominator
      Rational(num + num_a, @denominator * a.denominator)
    elsif a.kind_of?(Integer)
      self + Rational(a, 1)
    elsif a.kind_of?(Float)
      Float(self) + a
    else
      x, y = a.coerce(self)
      x + y
    end
  end

  #
  # Returns the difference of this value and +a+.
  # subtracted.
  #
  # Examples:
  #   r = Rational(3,4)    # -> Rational(3,4)
  #   r - 1                # -> Rational(-1,4)
  #   r - 0.5              # -> 0.25
  #
  def - (a)
    if a.kind_of?(Rational)
      num = @numerator * a.denominator
      num_a = a.numerator * @denominator
      Rational(num - num_a, @denominator*a.denominator)
    elsif a.kind_of?(Integer)
      self - Rational(a, 1)
    elsif a.kind_of?(Float)
      Float(self) - a
    else
      x, y = a.coerce(self)
      x - y
    end
  end

  #
  # Returns the product of this value and +a+.
  #
  # Examples:
  #   r = Rational(3,4)    # -> Rational(3,4)
  #   r * 2                # -> Rational(3,2)
  #   r * 4                # -> Rational(3,1)
  #   r * 0.5              # -> 0.375
  #   r * Rational(1,2)    # -> Rational(3,8)
  #
  def * (a)
    if a.kind_of?(Rational)
      num = @numerator * a.numerator
      den = @denominator * a.denominator
      Rational(num, den)
    elsif a.kind_of?(Integer)
      self * Rational(a, 1)
    elsif a.kind_of?(Float)
      Float(self) * a
    else
      x, y = a.coerce(self)
      x * y
    end
  end

  #
  # Returns the quotient of this value and +a+.
  #   r = Rational(3,4)    # -> Rational(3,4)
  #   r / 2                # -> Rational(3,8)
  #   r / 2.0              # -> 0.375
  #   r / Rational(1,2)    # -> Rational(3,2)
  #
  def divide (a)
    if a.kind_of?(Rational)
      num = @numerator * a.denominator
      den = @denominator * a.numerator
      Rational(num, den)
    elsif a.kind_of?(Integer)
      raise ZeroDivisionError, "division by zero" if a == 0
      self / Rational(a, 1)
    elsif a.kind_of?(Float)
      Float(self) / a
    else
      redo_coerced :/, a
    end
  end

  alias_method :/, :divide

  #
  # Returns this value raised to the given power.
  #
  # Examples:
  #   r = Rational(3,4)    # -> Rational(3,4)
  #   r ** 2               # -> Rational(9,16)
  #   r ** 2.0             # -> 0.5625
  #   r ** Rational(1,2)   # -> 0.866025403784439
  #
  def ** (other)
    if other.kind_of?(Rational)
      if self == 0 && other < 0 && other.denominator == 1
        raise ZeroDivisionError, "divided by 0"
      end
      Float(self) ** other
    elsif other.kind_of?(Integer)
      if self == 0 && other < 0
        raise ZeroDivisionError, "divided by 0"
      end
      if other > 0
        num = @numerator ** other
        den = @denominator ** other
      elsif other < 0
        num = @denominator ** -other
        den = @numerator ** -other
      elsif other == 0
        num = 1
        den = 1
      end
      Rational(num, den)
    elsif other.kind_of?(Float)
      Float(self) ** other
    else
      x, y = other.coerce(self)
      x ** y
    end
  end

  def div(other)
    (self / other).floor
  end

  #
  # Returns the remainder when this value is divided by +other+.
  #
  # Examples:
  #   r = Rational(7,4)    # -> Rational(7,4)
  #   r % Rational(1,2)    # -> Rational(1,4)
  #   r % 1                # -> Rational(3,4)
  #   r % Rational(1,7)    # -> Rational(1,28)
  #   r % 0.26             # -> 0.19
  #
  def % (other)
    if other == 0.0
      raise ZeroDivisionError, "division by zero"
    end
    value = (self / other).floor
    return self - other * value
  end

  #
  # Returns the quotient _and_ remainder.
  #
  # Examples:
  #   r = Rational(7,4)        # -> Rational(7,4)
  #   r.divmod Rational(1,2)   # -> [3, Rational(1,4)]
  #
  def divmod(other)
    if other.is_a?(Float) && other == 0.0
      raise ZeroDivisionError, "division by zero"
    end
    value = (self / other).floor
    return value, self - other * value
  end

  #
  # Returns the absolute value.
  #
  def abs
    if @numerator > 0
      self
    else
      Rational(-@numerator, @denominator)
    end
  end

  #
  # Returns +true+ iff this value is numerically equal to +other+.
  #
  # But beware:
  #   Rational(1,2) == Rational(4,8)          # -> true
  #
  def == (other)
    if other.kind_of?(Rational)
      @numerator == other.numerator and (@denominator == other.denominator or @numerator.zero?)
    elsif other.kind_of?(Integer)
      self == Rational(other, 1)
    elsif other.kind_of?(Float)
      Float(self) == other
    else
      other == self
    end
  end

  #
  # Standard comparison operator.
  #
  def <=> (other)
    if other.kind_of?(Rational)
      num = @numerator * other.denominator
      num_a = other.numerator * @denominator
      v = num - num_a
      if v > 0
        return 1
      elsif v < 0
        return  -1
      else
        return 0
      end
    elsif other.kind_of?(Integer)
      return self <=> Rational(other, 1)
    elsif other.kind_of?(Float)
      return Float(self) <=> other
    elsif defined? other.coerce
      x, y = other.coerce(self)
      return x <=> y
    else
      return nil
    end
  end

  def coerce(other)
    if other.kind_of?(Float)
      return other, self.to_f
    elsif other.kind_of?(Integer)
      return Rational(other, 1), self
    else
      super
    end
  end

  #
  # Converts the rational to an Integer.  Not the _nearest_ integer, the
  # truncated integer.  Study the following example carefully:
  #   Rational(+7,4).to_i             # -> 1
  #   Rational(-7,4).to_i             # -> -1
  #   (-1.75).to_i                    # -> -1
  #
  # In other words:
  #   Rational(-7,4) == -1.75                 # -> true
  #   Rational(-7,4).to_i == (-1.75).to_i     # -> true
  #

  def floor
    @numerator.div(@denominator)
  end

  def ceil
    -((-@numerator).div(@denominator))
  end

  def truncate
    if @numerator < 0
      return -((-@numerator).div(@denominator))
    end
    @numerator.div(@denominator)
  end

  alias_method :to_i, :truncate

  def round
    if @numerator < 0
      num = -@numerator
      num = num * 2 + @denominator
      den = @denominator * 2
      -(num.div(den))
    else
      num = @numerator * 2 + @denominator
      den = @denominator * 2
      num.div(den)
    end
  end

  #
  # Converts the rational to a Float.
  #
  def to_f
    @numerator.to_f/@denominator.to_f
  end

  #
  # Returns a string representation of the rational number.
  #
  # Example:
  #   Rational(3,4).to_s          #  "3/4"
  #   Rational(8).to_s            #  "8"
  #
  def to_s
    @numerator.to_s+"/"+@denominator.to_s
  end

  #
  # Returns +self+.
  #
  def to_r
    self
  end

  #
  # Returns a reconstructable string representation:
  #
  #   Rational(5,8).inspect     # -> "Rational(5, 8)"
  #
  def inspect
    "(#{to_s})"
  end

  #
  # Returns a hash code for the object.
  #
  def hash
    @numerator.hash ^ @denominator.hash
  end

  attr_reader :numerator
  attr_reader :denominator

  private :initialize

  #
  # Returns a simpler approximation of the value if an optional
  # argument eps is given (rat-|eps| <= result <= rat+|eps|), self
  # otherwise.
  #
  # For example:
  #
  #    r = Rational(5033165, 16777216)
  #    r.rationalize                    #=> (5033165/16777216)
  #    r.rationalize(Rational('0.01'))  #=> (3/10)
  #    r.rationalize(Rational('0.1'))   #=> (1/3)
  #
  def rationalize(eps=undefined)
    if eps.equal?(undefined)
      self
    else
      e = eps.abs
      a = self - e
      b = self + e

      p0 = 0
      p1 = 1
      q0 = 1
      q1 = 0

      while true
        c = a.ceil
        break if c < b
        k = c - 1
        p2 = k * p1 + p0
        q2 = k * q1 + q0
        t = 1 / (b - k)
        b = 1 / (a - k)
        a = t
        p0 = p1
        q0 = q1
        p1 = p2
        q1 = q2
      end

      Rational(c * p1 + p0, c * q1 + q0)
    end
  end
end

class Fixnum
  remove_method :quo

  # If Rational is defined, returns a Rational number instead of a Fixnum.
  def quo(other)
    Rational(self, 1) / other
  end
  alias rdiv quo

  # Returns a Rational number if the result is in fact rational (i.e. +other+ < 0).
  def rpower (other)
    if other >= 0
      self.power!(other)
    else
      Rational(self, 1)**other
    end
  end
end

class Bignum
  remove_method :quo

  # If Rational is defined, returns a Rational number instead of a Float.
  def quo(other)
    Rational(self, 1) / other
  end
  alias rdiv quo

  # Returns a Rational number if the result is in fact rational (i.e. +other+ < 0).
  def rpower (other)
    if other >= 0
      self.power!(other)
    else
      Rational(self, 1)**other
    end
  end
end

unless 1.respond_to?(:power!)
  class Fixnum
    alias_method :power!, :"**"
    alias_method :"**", :rpower
  end

  class Bignum
    alias_method :power!, :"**"
    alias_method :"**", :rpower
  end
end
