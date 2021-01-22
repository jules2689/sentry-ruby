require 'sentry/sidekiq/context_filter'

module Sentry
  module Sidekiq
    class ErrorHandler
      SIDEKIQ_NAME = "Sidekiq".freeze

      def call(ex, context)
        Rails.logger.info "I am here 1"
        return unless Sentry.initialized?
        Rails.logger.info "I am here 2"
        context = Sentry::Sidekiq::ContextFilter.new.filter_context(context)
        Rails.logger.info "I am here 3 #{context}"
        scope = Sentry.get_current_scope
        scope.set_transaction_name(transaction_from_context(context)) unless scope.transaction_name

        Sentry::Sidekiq.capture_exception(
          ex,
          extra: { sidekiq: context },
          hint: { background: false }
        )
      end

      private

      # this will change in the future:
      # https://github.com/mperham/sidekiq/pull/3161
      def transaction_from_context(context)
        classname = (context["wrapped"] || context["class"] ||
                      (context[:job] && (context[:job]["wrapped"] || context[:job]["class"]))
                    )
        if classname
          "#{SIDEKIQ_NAME}/#{classname}"
        elsif context[:event]
          "#{SIDEKIQ_NAME}/#{context[:event]}"
        else
          SIDEKIQ_NAME
        end
      end
    end
  end
end
