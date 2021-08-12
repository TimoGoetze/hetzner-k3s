module Hetzner
  class Firewall
    def initialize(hetzner_client:, cluster_name:)
      @hetzner_client = hetzner_client
      @cluster_name = cluster_name
    end

    def create
      puts

      if firewall = find_firewall
        puts "Firewall already exists, skipping."
        puts
        return firewall["id"]
      end

      puts "Creating firewall..."

      response = hetzner_client.post("/firewalls", firewall_config).body
      puts "...firewall created."
      puts

      JSON.parse(response)["firewall"]["id"]
    end

    def delete
      if firewall = find_firewall
        puts "Deleting firewall..."
        hetzner_client.delete("/firewalls", firewall["id"])
        puts "...firewall deleted."
      else
        puts "Firewall no longer exists, skipping."
      end

      puts
    end

    private

      attr_reader :hetzner_client, :cluster_name, :firewall

      def firewall_config
        {
          name: cluster_name,
          rules: [
            {
              "direction": "in",
              "protocol": "tcp",
              "port": "22",
              "source_ips": [
                "0.0.0.0/0",
                "::/0"
              ],
              "destination_ips": []
            },
            {
              "direction": "in",
              "protocol": "icmp",
              "port": nil,
              "source_ips": [
                "0.0.0.0/0",
                "::/0"
              ],
              "destination_ips": []
            },
            {
              "direction": "in",
              "protocol": "tcp",
              "port": "6443",
              "source_ips": [
                "0.0.0.0/0",
                "::/0"
              ],
              "destination_ips": []
            },
            {
              "direction": "in",
              "protocol": "tcp",
              "port": "any",
              "source_ips": [
                "10.0.0.0/16"
              ],
              "destination_ips": []
            },
            {
              "direction": "in",
              "protocol": "udp",
              "port": "any",
              "source_ips": [
                "10.0.0.0/16"
              ],
              "destination_ips": []
            }
          ]
        }
      end

      def find_firewall
        hetzner_client.get("/firewalls")["firewalls"].detect{ |firewall| firewall["name"] == cluster_name }
      end

  end
end