
PIP=$(hostname -I | awk '{print $1}')

# Perform action based on the number of arguments
if [ "$#" -eq 1 ]; then
    kubectl patch svc $1 -p '{"spec": {"externalIPs": ["'$PIP'"]}}'
    exit 1
elif [ "$#" -eq 2 ]; then
    kubectl patch svc $1 -n $2 -p '{"spec": {"externalIPs": ["'$PIP'"]}}'
    exit 1
else
    echo "Error: Too many arguments provided."
    exit 1
fi

#kubectl patch svc $1 -p '{"spec": {"externalIPs": ["'$PIP'"]}}'
