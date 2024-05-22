# Q1.
# 次の動作をする A1 class を実装する
# - "//" を返す "//"メソッドが存在すること

class A1
  define_method '//' do
    '//'
  end
end

# Q2.
# 次の動作をする A2 class を実装する
# - 1. "SmartHR Dev Team"と返すdev_teamメソッドが存在すること
# - 2. initializeに渡した配列に含まれる値に対して、"hoge_" をprefixを付与したメソッドが存在すること
# - 2で定義するメソッドは下記とする
#   - 受け取った引数の回数分、メソッド名を繰り返した文字列を返すこと
#   - 引数がnilの場合は、dev_teamメソッドを呼ぶこと
# - また、2で定義するメソッドは以下を満たすものとする
#   - メソッドが定義されるのは同時に生成されるオブジェクトのみで、別のA2インスタンスには（同じ値を含む配列を生成時に渡さない限り）定義されない

class A2
  def dev_team
    'SmartHR Dev Team'
  end

  def initialize(arr)
    arr.each do |name|
      # メモ:
      # A2の別のインスタンスには定義しない=インスタンスの特異メソッドとして定義する必要がある
      define_singleton_method("hoge_#{name}") do |count = nil|
        count.nil? ? dev_team : "hoge_#{name}" * count
      end
    end
  end
end

A2.new(%w(a b c)).hoge_a(3)
# A2.new(%w(d e f)).hoge_a(3) # => NoMethodError

# Q3.
# 次の動作をする OriginalAccessor モジュール を実装する
# - OriginalAccessorモジュールはincludeされたときのみ、my_attr_accessorメソッドを定義すること
# - my_attr_accessorはgetter/setterに加えて、boolean値を代入した際のみ真偽値判定を行うaccessorと同名の?メソッドができること

module OriginalAccessor
  def self.included(base)
    # メモ:
    # my_attr_accessorはクラスマクロとして定義したい
    # つまりbaseをselfとして呼び出し可能なメソッドである必要があり、すなわちクラスメソッドを定義する必要がある
    # そのためbaseの特異クラスをオープンしてそこにメソッドmy_attr_accessorを定義してやればよい
    class << base

      def my_attr_accessor(name)
        # メモ:
        # ここでのdefine_methodはインスタンスメソッドを定義するためのもの
        # base.define_methodになるので普通にインスタンスメソッドになる
        define_method(name) do
          instance_variable_get("@#{name}")
        end

        define_method("#{name}=") do |value|
          instance_variable_set("@#{name}", value)
          if value.is_a?(TrueClass) || value.is_a?(FalseClass)
            # メモ:
            # setter呼び出し時の値に応じて?付きメソッドを用意する
            # setter呼び出し時のselfが何かを考えてやればよくて、selfはインスタンスであり、インスタンスからインスタンスメソッドを定義するには？
            # 特異メソッドを定義してやればよい
            define_singleton_method("#{name}?") { value }
          end
        end
      end
    end
  end
end

class Hoge
  include OriginalAccessor

  my_attr_accessor :hoge
end

hoge = Hoge.new
hoge.hoge = true
hoge.hoge?

