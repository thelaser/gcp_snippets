def getrekt(data, context):
    """
    Instadeletes files uploaded to a bucket.
    """
    
    print("Don't upload files to my bucket named "+data['bucket']+" !!!1 Imma delete this "+data['name']+" file!!!!!")
    
    from google.cloud import storage
    storage_client = storage.Client()
    bucket = storage_client.get_bucket(data['bucket'])
    deleteblob = bucket.blob(data['name'])
    deleteblob.delete()
