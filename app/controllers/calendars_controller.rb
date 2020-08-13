class CalendarsController < ApplicationController

  # １週間のカレンダーと予定が表示されるページ
  def index
    get_week
    @plan = Plan.new
  end

  # 予定の保存
  def create
    Plan.create(plan_params)
    redirect_to action: :index
  end

  private

  def plan_params
    params.require(:plan).permit(:date, :plan)
  end

  def get_week
    wdays = ['(日)','(月)','(火)','(水)','(木)','(金)','(土)']

    # Dateオブジェクトは、日付を保持しています。下記のように`.today.day`とすると、今日の日付を取得できます。
    @todays_date = Date.today
    # 例) 今日が2月1日の場合・・・ Date.today.day => 1日

    @week_days = []

    @plans = Plan.where(date: @todays_date..@todays_date + 7)

    7.times do |x|
      plans = []
      plan = @plans.map do |plan|
        plans.push(plan.plan) if plan.date == @todays_date + x
      end
      # :monthで月を取得している
      # @today_dateは今日の日付を表示されるだけなので、明日、明後日、明々後日と出力させるためには,timesメソッドのブロック変数であるxを足さなければならない
      # 日と違い、わざわざ（）で括っている理由は、月をまたぐ場合があったとしてもきちんと出力するようにするため
      # 例えば、7月29日から8月4日を表示されるとき、（）で括らないと7月29日から7月4日と表示されてしまうだろう多分
      # 曜日はwdaysという配列を使い、表示する必要がある
      # 具体的には、wdays["添字"]と配列に角カッコで添字を与えることで曜日が取得できる
      # 曜日の場合、先にwdaysと配列を定義しあらかじめ曜日を書いているため、日のように最後にxを足してしまうと、配列の最後である(土)までいくと配列が終わり、曜日が出力されなくなってしまう
      # xを足す順番を工夫することでこの問題は解消される
      # まず月で書いた時と同様に日にちにxを足し、次に.wdayとその今日の曜日を取得し、それを添字として角カッコで定義することで無事曜日が出力される
      days = { :month => (@todays_date + x).month, :date => @todays_date.day + x, :wday => wdays[(@todays_date + x).wday], :plans => plans}
      # pushメソッドは配列の末尾に引数を要素として追加するメソッド
      # 引数は複数指定することもでき、その場合は指定した順番に配列に追加される
      # pushはレシーバーであるオブジェクトを変更してしまう破壊的メソッド
      # 基本的に破壊的メソッドは末尾に!をつける場合が多いが、pushメソッドは!がついていないのに破壊的メソッドになる
      # ここでは、@week_daysというからの配列に破壊的メソッドであるpushを用い、daysという要素を配列の末尾に追加している
      @week_days.push(days)
    end
  end
end