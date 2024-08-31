import json
import subprocess

def get_terraform_output():
    # Run terraform output command and capture the output
    result = subprocess.run(['terraform', 'output', '-json'], capture_output=True, text=True)
    return json.loads(result.stdout)

def generate_inventory(output):
    instance_ips = output['instance_ips']['value']
    
    inventory_content = "[windows_instances]\n"
    for ip in instance_ips:
        inventory_content += f"{ip}\n"
    
    inventory_content += "\n[windows_instances:vars]\n"
    inventory_content += "ansible_user=Administrator\n"
    inventory_content += "ansible_connection=winrm\n"
    inventory_content += "ansible_winrm_server_cert_validation=ignore\n"
    
    with open('inventory.ini', 'w') as f:
        f.write(inventory_content)

if __name__ == "__main__":
    tf_output = get_terraform_output()
    generate_inventory(tf_output)
    print("Ansible inventory file 'inventory.ini' has been generated.")
