# ブラウザ作業自動化サービス 『Automiser』

## 概要
社内で利用している勤怠管理アプリへの勤怠入力の手間を削減するブラウザ作業自動化サービスです。  
勤怠管理アプリへ登録されている勤務予定データを取り込み、そのデータを勤務実績データとして登録します。  

## URL
### https://automiser.net/

## 機能一覧
| No. | 機能         |
| --- | ---------- |
| 1   | ユーザー機能     |
| 2   | 勤務予実取得機能   |
| 3   | 勤務実績手動修正機能   |
| 4   | 勤務実績自動登録機能 |


## 使用技術
- ### フロントエンド
  - #### HTML/CSS、Tailwind CSS
- ### バックエンド
  - #### Ruby、Rails
- #### インフラ
  - #### AWS（VPC、Route53、 ACM、ALB、EC2、RDS）
  - #### MySQL
  - #### Ubuntu

## ER図
```mermaid
erDiagram
  Employee ||--o{ TimeCard: ""

  Employee {
    id                      bigint(20)    PK  ""
    emp_no                  int(11)           "社員番号"
    encrypted_password      varchar(191)      ""
    reset_password_token    varchar(191)      ""
    reset_password_sent_at  datetime          ""
    remember_created_at     datetime          ""
    created_at              datetime(6)       ""
    updated_at              datetime(6)       ""
  }
  TimeCard {
    id                      bigint(20)    PK  ""
    employee_id             int(11)       FK  ""
    date                    date              "日付"
    start_time_scheduled    time              "勤務開始予定時刻"
    end_time_scheduled      time              "勤務終了予定時刻"
    start_time_actual       time              "勤務開始実績時刻"
    end_time_actual         time              "勤務終了実績時刻"
    break_start_time        time              "休憩開始時間"
    break_end_time          time              "休憩終了時間"
    holiday_status          varchar(191)      "休日ステータス"
    application_status      varchar(191)      "申請ステータス"
    comment                 varchar(191)      "コメント"
    created_at              datetime(6)       "作成日時"
    updated_at              datetime(6)       "更新日時"
  }
```

## インフラ構成図
![](documents/Diagram.drawio.png)
