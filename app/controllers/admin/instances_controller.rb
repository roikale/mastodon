# frozen_string_literal: true

module Admin
  class InstancesController < BaseController
    def index
      @instances = ordered_instances
    end

    def resubscribe
      params.require(:by_domain)
      Pubsubhubbub::SubscribeWorker.push_bulk(subscribeable_accounts.pluck(:id))
      redirect_to admin_instances_path
    end

    private

    def paginated_instances
      Account.remote.by_domain_accounts.page(params[:page])
    end

    helper_method :paginated_instances

    def ordered_instances
      paginated_instances.map { |account| Instance.new(account) }
    end

    def subscribeable_accounts
      Account.with_followers.remote.where(domain: params[:by_domain])
    end
  end
end
