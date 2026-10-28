module Dashboard
  # Single navigation definition backing every sidebar item, its badges, and its
  # preview status (FR-019 to FR-024). Only Dashboard is routable.
  class Navigation
    GROUPS = [
      { label: "General", items: [
        { key: "dashboard", label: "Dashboard", icon: "layout-dashboard", href: "/dashboard" },
        { key: "payment", label: "Payment", icon: "credit-card" },
        { key: "customers", label: "Customers", icon: "users" },
        { key: "message", label: "Message", icon: "message-square", badge: :messages }
      ] },
      { label: "Tools", items: [
        { key: "product", label: "Product", icon: "package" },
        { key: "invoice", label: "Invoice", icon: "receipt" },
        { key: "analytics", label: "Analytics", icon: "bar-chart-3" },
        { key: "automation", label: "Automation", icon: "workflow", badge: :beta }
      ] },
      { label: "Support", items: [
        { key: "settings", label: "Settings", icon: "settings" },
        { key: "security", label: "Security", icon: "shield-check" },
        { key: "help", label: "Help", icon: "help-circle" }
      ] }
    ].freeze

    def initialize(workspace:)
      @workspace = workspace
    end

    def payload
      unread = workspace.unread_message_count

      {
        groups: GROUPS.map do |group|
          { label: group[:label], items: group[:items].map { |item| item_payload(item, unread) } }
        end,
        workspace: { name: workspace.name, plan: workspace.plan },
        unread_count: unread
      }
    end

    private
      attr_reader :workspace

      def item_payload(item, unread)
        href = item[:href]

        {
          key: item[:key],
          label: item[:label],
          icon: item[:icon],
          href: href,
          active: href.present?,
          disabled: href.blank?,
          badge: badge_for(item[:badge], unread)
        }
      end

      def badge_for(kind, unread)
        case kind
        when :messages then unread.positive? ? { text: unread.to_s, variant: "secondary" } : nil
        when :beta then { text: "BETA", variant: "beta" }
        end
      end
  end
end
