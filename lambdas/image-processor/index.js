const aws = require('aws-sdk')

const rekognition = new aws.Rekognition()
const s3 = new aws.S3()

const generateTagSets = labels => {
  return labels.map((l, i) => ({ Key: `Object-${i + 1}`, Value: l.Name }))
}

const addObjectTags = async (bucketName, key, labels) => {
  const params = {
    Bucket: bucketName,
    Key: key,
    Tagging: {
      TagSet: generateTagSets(labels),
    },
  }

  await s3.putObjectTagging(params).promise()
}

const detectLabels = async (bucketName, key) => {
  const params = {
    Image: {
      S3Object: {
        Bucket: bucketName,
        Name: key,
      },
    },
    MaxLabels: '10',
    MinConfidence: '50',
  }

  const labels = await rekognition
    .detectLabels(params)
    .promise()
    .then(data => data.Labels)

  return labels
}

const processRecord = async record => {
  const bucketName = record.s3.bucket.name
  const key = record.s3.object.key

  const labels = await detectLabels(bucketName, key)
  await addObjectTags(bucketName, key, labels)
}

exports.lambda_handler = async (event, context, callback) => {
  try {
    event.Records.forEach(processRecord)
    callback(null, { status: 'success' })
  } catch (err) {
    console.error(err)
    callback(err)
  }
}
