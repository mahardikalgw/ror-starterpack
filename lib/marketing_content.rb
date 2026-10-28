##
# Server-side landing page copy. Kept in Ruby (not fetched by the client) so the
# page renders without a second data source and contains no workspace analytics.
module MarketingContent
  VALUE_PROPS = [
    { icon: "layout-dashboard", title: "A dashboard that looks finished",
      description: "Sidebar navigation, KPI cards, and three chart panels laid out like a production analytics product." },
    { icon: "database", title: "Backed by real records",
      description: "Every figure is aggregated from seeded SQLite data, so filters, periods, and exports actually recalculate." },
    { icon: "shield-check", title: "Authentication included",
      description: "Email and password sign-in with server-side sessions, rate limiting, and a signed-in route guard." }
  ].freeze

  PROOF = [
    { metric: "46", label: "functional requirements covered" },
    { metric: "9", label: "normalized data tables" },
    { metric: "3", label: "pages wired end to end" }
  ].freeze

  FOOTER_LINKS = [
    { label: "Dashboard", href: "/dashboard", available: true },
    { label: "Payment", href: nil, available: false },
    { label: "Customers", href: nil, available: false },
    { label: "Analytics", href: nil, available: false }
  ].freeze

  def self.payload(signed_in:)
    {
      signed_in: signed_in,
      primary_cta: signed_in ? { label: "Open dashboard", href: "/dashboard" } : { label: "Start for free", href: "/registration/new" },
      secondary_cta: signed_in ? nil : { label: "Sign in", href: "/session/new" },
      value_props: VALUE_PROPS,
      proof: PROOF,
      preview: {
        title: "Dashboard preview",
        description: "Three metric cards, regional sales, weekly subscribers, and channel distribution — all computed server-side."
      },
      footer_links: FOOTER_LINKS
    }
  end
end
