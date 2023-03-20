<#
Para instalar Docker en una máquina virtual y que los contenedores sean visibles 
desde el host (y cualquiera en la red)
#>

<#1.  
En VBox lo he solucionado poniendo la misma MAC para la red virtual que la mía.
    Crear dos redes
        - Adaptador 1. Adaptador sólo-anfitrión. Configurar este para que tenga DHCP en VBox.
        - Adaptador 2. Adaptador puente
En HyperV
#>

#2. Se instala el docker normal

#3. Se crea una nueva red "transparente"
docker network create -d transparent dockernet
    #dockernet es el nombre de la red.
    #3a. Revisa que la red se ha creado
        docker network ls

<#4. 

Cuando crees el contenedor, hay que añadir la opción:
    -additionalparameters @("--network=dockernet")

Si ya tenias el contenedor creado puedes,
    Buscar en que red está conectado. Posiblemente en nat
    docker network inspect nat
        Veras un xml, en la pestaña Containers, debe aparecer el tuyo.
    
    Desconectarlo de esa red
        docker network disconnect nat "nombreContenedor"
    
    Conectarlo a la nueva red
    docker network connect dockernet "nombreContenedor"
#>

#4a. Confirma que la IP de tu contenedor es del rango "normal"
    #Ve al terminal del contenedor y pon ipconfig
    
<#5. 
    Tu contenedor deberia ser visible ya desde cualquier ordenador de la red. 
    Se puede usar el nombre, como si estuvieras en local
#>