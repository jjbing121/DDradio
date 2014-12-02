
import UIKit
import Foundation

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, HttpProtocol {
    // 本页面的基础组件基础引用，也就是组件与类进行关联的方式
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var lv: UIImageView!

    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressTime: UILabel!
    
    var Ohttp:HttpController = HttpController()
    
    // 全局定义外部使用变量
    var tableData:NSArray = NSArray()
    var channelData:NSArray = NSArray()
    // 缓存缩略图
    var imageCache = Dictionary<String, UIImage>()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        Ohttp.delegate = self
        Ohttp.onSearch("http://www.douban.com/j/app/radio/channels")
        Ohttp.onSearch("http://douban.fm/j/mine/playlist?channel=0")
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Return -> TableView Row's Count
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return tableData.count
    }
    // 返回指定的单元格 cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Doubans")
        let rowData:NSDictionary = self.tableData[indexPath.row] as NSDictionary

        cell.textLabel.text = rowData["title"] as? String           // 标题
        cell.detailTextLabel?.text = rowData["artist"] as? String   // 详细歌手
        cell.imageView.image = UIImage(named: "default.png")        // 设置一个默认图片 特别注意:  UIImage的第1种用法，直接获取从本地文件中获取内容
        let imgurl = rowData["picture"] as String
        let image = self.imageCache[imgurl]
        if (image? == nil) {
            // 如果图片在缓存中不存在的情况，则加载
            let reurl = NSURL(string: imgurl)
            let reResponse = NSURLRequest(URL: reurl!)
            NSURLConnection.sendAsynchronousRequest(reResponse, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!, data:NSData!, error:NSError!) -> Void in
                let get_img = UIImage(data: data)  // 特别注意:  UIImage的第2种用法，直接获取从NSData里面取得的内容
                cell.imageView.image = get_img
                self.imageCache[imgurl] = get_img
            })
        } else {
            cell.imageView.image = image
        }
        
        return cell
    }
    
    func didReceiveResult(results:NSDictionary)
    {
        if (results["song"] != nil) {
            self.tableData = results["song"] as NSArray
            self.tv.reloadData()
        } else if (results["channels"] != nil) {
            self.channelData = results["channels"] as NSArray
        }
    }
}
