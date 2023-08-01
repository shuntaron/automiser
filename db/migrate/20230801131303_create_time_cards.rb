class CreateTimeCards < ActiveRecord::Migration[7.0]
  def change
    create_table :time_cards do |t|
      t.integer :employee_id
      t.date :date
      t.time :start_time_scheduled
      t.time :end_time_scheduled
      t.time :start_time_actual
      t.time :end_time_actual
      t.time :break_start_time
      t.time :break_end_time
      t.string :holiday_status
      t.string :application_status
      t.string :comment

      t.timestamps
    end
  end
end
