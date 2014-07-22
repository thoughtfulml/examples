require 'narray'
require 'nmatrix'

module NMatrixHack
  def determinant
    raise "Must be square" unless square?·
    size = self.sizes[1]
    last = size - 1
    a = self.to_a
    no_pivot = Proc.new{ return 0 }
    sign = +1·
    pivot = 1.0
    size.times do |k|
      previous_pivot = pivot
      if (pivot = a[k][k].to_f).zero?
        switch = (k+1 ... size).find(no_pivot) {|row|
          a[row][k] != 0
        }
        a[switch], a[k] = a[k], a[switch]
        pivot = a[k][k]
        sign = -sign
      end
      (k+1).upto(last) do |i|
        ai = a[i]
        (k+1).upto(last) do |j|
          ai[j] = (pivot * ai[j] - ai[k] * a[k][j]) / previous_pivot
        end
      end
    end·
    sign * pivot
  end
····
  def singular?·
    determinant == 0
  end

  def square?
    sizes[0] == sizes[1]
  end·

  def regular?
    !singular?
  end
end

NMatrix.send(:include, NMatrixHack)
