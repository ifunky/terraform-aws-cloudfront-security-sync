resource "aws_cloudwatch_dashboard" "main" {
  count          = var.create_dashboard == "true" ? 1 : 0
  dashboard_name = "CloudFront_IP_SpaceChanged"

  dashboard_body = <<EOF
{
    "widgets": [
        {
            "type": "metric",
            "x": 0,
            "y": 0,
            "width": 12,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "CloudFrontIpSync", "CloudFrontGlobalIpSyncHttpsCount", { "yAxis": "left" } ],
                    [ ".", "CloudFrontRegionIpSyncHttpsCount" ]
                ],
                "view": "timeSeries",
                "stacked": true,
                "region": "${var.region}",
                "setPeriodToTimeRange": true,
                "title": "CloudFront IP Space Changes",
                "yAxis": {
                    "left": {
                        "label": "Changes",
                        "showUnits": true
                    },
                    "right": {
                        "label": "Date",
                        "showUnits": true
                    }
                },
                "legend": {
                    "position": "right"
                }
            }
        }
    ]
}
 EOF
}