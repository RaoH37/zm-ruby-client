# frozen_string_literal: true

module Zm
  module Client
    class MtaQueue < Base::Object
      extend Relationship
      has_jsns_builder
      include Zm::Utils::HasSoapAdminConnector

      attr_accessor :name, :n

      alias nb_items n

      def server
        @parent
      end

      has_many :items, klass: :'Zm::Client::MtaQueueItemsCollection'

      def hold!(ids)
        sac.invoke(jsns_builder.to_jsns(Zm::Client::MtaQueueAction::HOLD, ids))
      end

      def release!(ids)
        sac.invoke(jsns_builder.to_jsns(Zm::Client::MtaQueueAction::RELEASE, ids))
      end

      def delete!(ids)
        sac.invoke(jsns_builder.to_jsns(Zm::Client::MtaQueueAction::DELETE, ids))
      end

      def requeue!(ids)
        sac.invoke(jsns_builder.to_jsns(Zm::Client::MtaQueueAction::REQUEUE, ids))
      end
    end
  end
end
