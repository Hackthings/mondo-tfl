namespace :mt do
  task pull_and_attach: :environment do
    Rake::Task["mt:refresh_user_tokens"].invoke
    Rake::Task["mt:pull_journeys"].invoke
    Rake::Task["mt:attach_receipts"].invoke
  end

  task refresh_user_tokens: :environment do
    users = User.order(:id)
    users = users.where(id: ENV['USER_ID']) if ENV['USER_ID']
    users.all.each do |user|
      begin
        puts "#{user.name}"
        puts "Refreshing Token"
        user.request_new_token
      rescue => e
        puts "ERROR Refreshing token for USER: #{user.name} <#{user.uid}> #{e}."
      end
    end
  end

  task pull_journeys: :environment do
    users = User.order(:id)
    users = users.where(id: ENV['USER_ID']) if ENV['USER_ID']
    users.all.each do |user|
      begin
        puts "Requesting Journeys for #{user.name} <#{user.uid}>"
        pjs = PullJourneysService.new(user: user)
        pjs.call
      rescue => e
        puts "ERROR requesting journeys for USER: #{user.name} <#{user.uid}> #{e}."
      end
    end
  end

  task attach_receipts: :environment do
    users = User.order(:id)
    users = users.where(id: ENV['USER_ID']) if ENV['USER_ID']
    overwrite = ENV['USER_ID'] && ENV['FORCE'] == 'true'
    users.all.each do |user|
      begin
        puts "Attaching Receipts to #{user.name} <#{user.uid}>"
        grs = GenerateReceiptsService.new(user: user, overwrite: overwrite)
        grs.call
      rescue => e
        puts "ERROR attaching receipts for USER: #{user.name} <#{user.uid}> #{e}."
      end
    end
  end

  task clear_receipts: :environment do
    users = User.order(:id)
    users = users.where(id: ENV['USER_ID']) if ENV['USER_ID']
    users.all.each do |user|
      next unless user.mondo.account_id
      txs = user.transactions
      txs.each do |tx|
        tx.attachments.first.deregister if tx.attachments.first
      end
    end
  end

  namespace :tip do
    task introduction: :environment do
      user = User.where(id: ENV['USER_ID']).first
      TFLIntroductionTipService.new(user: user).call
    end

    task incorrect_card: :environment do
      user = User.where(id: ENV['USER_ID']).first
      TFLTipIncorrectCardService.new(user: user).call
    end

    task peak: :environment do
      users = User.order(:id)
      users = users.where(id: ENV['USER_ID']) if ENV['USER_ID']
      users.all.each do |user|
        TFLPeakTipService.new(user: user).call
      end
    end
  end
end
