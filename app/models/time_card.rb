class TimeCard < ApplicationRecord
  def break_duration
    return unless break_start_time && break_end_time

    # 休憩時間の差分を計算
    duration_seconds = break_end_time - break_start_time
  
    # 時間と分を取得
    hours = (duration_seconds / 3600).to_i
    minutes = (duration_seconds / 60) % 60
  
    # HH:MM 形式でフォーマット
    format("%02d:%02d", hours, minutes)
  end
end
